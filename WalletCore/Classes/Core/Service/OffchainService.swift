//
//  OffchainService.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10/19/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class OffchainService {
    private let authManager: LWRxAuthManager
    private let privateKeyManager: LWPrivateKeyManager
    private let keychainManager: LWKeychainManager
    private let transactionManager: LWTransactionManager
    
    public static let instance: OffchainService = {
        return OffchainService(
            authManager: LWRxAuthManager.instance,
            privateKeyManager: LWPrivateKeyManager.shared(),
            keychainManager: LWKeychainManager.instance(),
            transactionManager: LWTransactionManager.shared()
        )
    }()
    
    public init(
        authManager: LWRxAuthManager,
        privateKeyManager: LWPrivateKeyManager,
        keychainManager: LWKeychainManager,
        transactionManager: LWTransactionManager
    ) {
        self.authManager = authManager
        self.privateKeyManager = privateKeyManager
        self.keychainManager = keychainManager
        self.transactionManager = transactionManager
    }
    
    public func trade(amount: Decimal, asset: LWAssetModel, forAsset: LWAssetModel) -> Observable<ApiResult<LWModelOffchainResult>> {
        let channelAsset = amount > 0 ? forAsset : asset
    
        //1. get channel key for asset
        let offchainChannelKey = authManager.offchainChannelKey.request(forAsset: channelAsset.identity)
        
        //decrypt chanel key with user key
        let decryptedKey = offchainChannelKey
            .filterSuccess()
            .decryptKey(withKeyManager: privateKeyManager)
            .replaceNilWithLastPrivateKey(keyChainManager: keychainManager, forAssetId: channelAsset.identity)
        
        //2. request offchain trading
        let offchainTrade = decryptedKey
            .map{ decryptedKey in
                return LWPacketOffchainTrade.Body(
                    asset: asset.identity,
                    assetPair: asset.getPairId(withAsset: forAsset),
                    prevTempPrivateKey: decryptedKey,
                    volume: amount
                )
            }
            .flatMapLatest{ [weak self] body in
                return self?.authManager.offchainTrade.request(withData: body) ?? Observable.never()
            }
            .shareReplay(1)
        
        //3. request chanel processing if trading returns success
        let offchainProcessChanel = offchainTrade
            .filterSuccess()
            .flatMapLatest{ [weak self] (offchainResult: LWModelOffchainResult) -> Observable<ApiResult<LWModelOffchainResult>> in
                guard let `self` = self else { return Observable.never() }
                return self.processChannel(withOffchainResult: offchainResult, transactionType: .createChannel)
            }
            .shareReplay(1)
        
        //4. finalize transfer if chanel processing is sucessful
        let offchainFinalizeTransfer = offchainProcessChanel
            .filterSuccess()
            .flatMapLatest{ [weak self] (offchainResult: LWModelOffchainResult) -> Observable<ApiResult<LWModelOffchainResult>> in
                guard let `self` = self else { return Observable.never() }
                return self.finalizeTransfer(withOffchainResult: offchainResult, channelAsset: channelAsset.identity)
            }
            .shareReplay(1)
        
        //Merge all error streams into one
        let errors = Observable.merge(
            offchainChannelKey.filterError(),
            offchainTrade.filterError(),
            offchainProcessChanel.filterError(),
            offchainFinalizeTransfer.filterError()
        ).map{ ApiResult<LWModelOffchainResult>.error(withData: $0) }
        
        let finalResult = offchainFinalizeTransfer
            .filterSuccess()
            .map{ ApiResult<LWModelOffchainResult>.success(withData: $0) }
    
        return Observable
            .merge(errors, finalResult)
            .startWith(ApiResult.loading)
            .shareReplay(1)
    }
    
    public func finalizePendingRequests() -> Disposable {
        //1. get pending actions
        let pendingActions = Observable<Int>
            .interval(60.0, scheduler: MainScheduler.instance)
            .startWith(0)
            .flatMapLatest{ [weak self] _ -> Observable<ApiResult<LWPacketCheckPendingActions>> in
                guard let `self` = self else { return Observable.never() }
                return self.authManager.checkPendingActions.request()
            }
        
        //2. get requests if there are pending offchain requests
        let requests = pendingActions
            .filterSuccess()
            .filter{ $0.hasOffchainRequests }
            .flatMapLatest{ [weak self] _ in self?.authManager.offchainRequests.request() ?? Observable.never() }
        
        // Filter first request and subscribe itself until all requests get finalized
        return requests.filterSuccess()
            .map{ $0.first }
            .filterNil()
            .flatMapLatest{ [weak self] request -> Observable<ApiResult<LWModelOffchainResult>> in
                guard let `self` = self else { return Observable.never() }
                return self.finalize(pendingRequest: request)
            }
            .filterSuccess()
            .subscribe(onNext: { [weak self] _ in
                _ = self?.finalizePendingRequests()
            })
    }
    
    private func finalize(pendingRequest request: LWModelOffchainRequest) -> Observable<ApiResult<LWModelOffchainResult>> {
        
        //1. get channel key
        let offchainChannelKey = self.authManager.offchainChannelKey.request(forAsset: request.assetId)
        
        //decrypt channel key
        let decryptedKey = offchainChannelKey
            .filterSuccess()
            .decryptKey(withKeyManager: privateKeyManager)
            .replaceNilWithLastPrivateKey(keyChainManager: keychainManager, forAssetId: request.assetId)
        
        //2. Sent request transfer
        let offchainRequestTransfer = decryptedKey.flatMapLatest{ key in
                self.authManager.offchainRequestTransfer.request(
                    withData: LWPacketRequestTransfer.Body(requestId: request.requestId, prevTempPrivateKey: key)
                )
            }
            .shareReplay(1)
        
        //3. Proccess chanel if opration result is 1
        let processedChanel = offchainRequestTransfer
            .filterSuccess()
            .filter{ $0.operationResult == 1 }
            .flatMapLatest{ [weak self] offchainResult -> Observable<ApiResult<LWModelOffchainResult>> in
                guard let `self` = self else { return Observable.never()}
                return self.processChannel(withOffchainResult: offchainResult, transactionType: .createChannel)
            }
            .shareReplay(1)
        
        //Merge request transfer with result 0 and processed chane; and finalize transfer
        let finalizedTransfer = Observable
            .merge(
                offchainRequestTransfer.filterSuccess().filter{ $0.operationResult == 0},
                processedChanel.filterSuccess()
            )
            .flatMapLatest{ [weak self]  offchainResult -> Observable<ApiResult<LWModelOffchainResult>> in
                guard let `self` = self else { return Observable.never() }
                return self.finalizeTransfer(withOffchainResult: offchainResult, channelAsset: request.assetId)
            }
            .shareReplay(1)
        
        return finalizedTransfer
    }
    
    public func processChannel(withOffchainResult offchainResult: LWModelOffchainResult,
                               transactionType: OffchainTransactionType) -> Observable<ApiResult<LWModelOffchainResult>> {
        
        return processChannel(
            transaction: offchainResult.transactionHex,
            transferId: offchainResult.transferId,
            transactionType: transactionType
        )
    }
    
    public func processChannel(transaction: String, transferId: String,
                               transactionType: OffchainTransactionType) -> Observable<ApiResult<LWModelOffchainResult>> {
                
        guard let signedChannelTransaction = LWTransactionManager.signOffchainTransaction(
            transaction,
            withKey: privateKeyManager.wifPrivateKeyLykke,
            type: transactionType
        ) else {
            return Observable.just(.error(withData: ["signedChannelTransaction": "Chanel transaction can not be signed."]))
        }
        
        return  authManager.offchainProcessChannel.request(
            withData: LWPacketOffchainProcessChannel.Body(
                transferId: transferId,
                signedChannelTransaction: signedChannelTransaction
            )
        )
    }
    
    public func finalizeTransfer(withOffchainResult offchainResult: LWModelOffchainResult,
                                 channelAsset: String) -> Observable<ApiResult<LWModelOffchainResult>>  {
        
        return finalizeTransfer(
            transaction: offchainResult.transactionHex,
            transferId: offchainResult.transferId,
            channelAsset: channelAsset
        )
    }
    
    public func finalizeTransfer(transaction: String, transferId: String,
                                 channelAsset: String) -> Observable<ApiResult<LWModelOffchainResult>>  {
        
        guard
            let key = privateKeyManager.generateKeyDict(),
            let wif = key["wif"] as? String,
            let publicKey = key["publicKey"] as? String
        else {
            return Observable.just(.error(withData: ["generateKey": "Can not generate key."]))
        }
        
        guard
            let wifPrivateKeyLykke = privateKeyManager.wifPrivateKeyLykke,
            let signedTransaction = LWTransactionManager.signOffchainTransaction(transaction, withKey: wifPrivateKeyLykke, type: .transfer)
        else {
            return Observable.just(.error(withData: ["signedTransaction": "Can not sign transaction."]))
        }
        
        return authManager.offchainFanilazeTransfer.request(withData: LWPacketOffchainFinalizetransfer.Body(
            transferId: transferId,
            clientRevokePubKey: publicKey,
            clientRevokeEncryptedPrivateKey: privateKeyManager.encryptExternalWalletKey(wif),
            signedTransferTransaction: signedTransaction
        ))
    }
}

fileprivate extension ObservableType where Self.E == LWModelOffchainChannelKey {
    func decryptKey(withKeyManager keyManager: LWPrivateKeyManager) -> Observable<String?> {
        return
            map{ $0.key }
            .map{ encryptedKey -> String? in
                return keyManager.decryptExternalWalletKey(encryptedKey)
            }
    }
}

fileprivate extension ObservableType where Self.E == String? {
    func replaceNilWithLastPrivateKey(keyChainManager keychainManager: LWKeychainManager, forAssetId assetId: String) -> Observable<String> {
        return map{key in
            guard let key = key else {
                return keychainManager.offchainLastPrivateKey(forAsset: assetId)
            }
            
            return key
        }
    }
}
