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
        
        //3. create channel if needed and finalize transfer
        let finalizedTransfer = offchainTrade
            .filterSuccess()
            .flatMap{ [weak self] offchainResult -> Observable<ApiResult<LWModelOffchainResult>> in
                guard let `self` = self else {return Observable.never()}
                return self.finalize(offchainResult: offchainResult, channelAssetId: channelAsset.identity)
            }
            .shareReplay(1)
        
        //Merge all error streams into one
        let errors = Observable.merge(
            offchainChannelKey.filterError(),
            offchainTrade.filterError(),
            finalizedTransfer.filterError()
        ).map{ ApiResult<LWModelOffchainResult>.error(withData: $0) }
        
        let finalResult = finalizedTransfer
            .filterSuccess()
            .map{ ApiResult<LWModelOffchainResult>.success(withData: $0) }
    
        return Observable
            .merge(errors, finalResult)
            .startWith(ApiResult.loading)
            .shareReplay(1)
    }
    
    public func finalizePendingRequests(refresh: Observable<Void>) -> Disposable {
        //1. get pending actions
        let pendingActions = refresh
            .flatMapLatest{ [weak self] _ -> Observable<ApiResult<LWPacketCheckPendingActions>> in
                guard let `self` = self else { return Observable.never() }
                return self.authManager.checkPendingActions.request()
            }
            .shareReplay(1)
        
        //2. get requests if there are pending offchain requests
        let requests = pendingActions
            .filterSuccess()
            .filter{ $0.hasOffchainRequests }
            .flatMapLatest{ [weak self] _ in self?.authManager.offchainRequests.request() ?? Observable.never() }
            .shareReplay(1)
        
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
                self?.finalizePendingRequests(refresh: refresh)
            })
    }
    
    private func finalize(offchainResult: LWModelOffchainResult, channelAssetId: String) -> Observable<ApiResult<LWModelOffchainResult>> {
        
        //If channel doesn't exist first create it (if oprerationResult == 1) otherwise just use given offchainResult
        let processedChanel = offchainResult.operationResult == 1 ?
            self.processChannel(withOffchainResult: offchainResult, transactionType: .createChannel) :
            Observable.just(ApiResult.success(withData: offchainResult))
        
        //Merge request transfer with result 0 and processed channel and finalize transfer
        let finalizedTransfer = processedChanel
            .filterSuccess()
            .flatMapLatest{ [weak self]  offchainResult -> Observable<ApiResult<LWModelOffchainResult>> in
                guard let `self` = self else { return Observable.never() }
                return self.finalizeTransfer(withOffchainResult: offchainResult, channelAsset: channelAssetId)
            }
            .shareReplay(1)
        
        let errors = Observable
            .merge(processedChanel.filterError(), finalizedTransfer.filterError())
            .map{ ApiResult<LWModelOffchainResult>.error(withData: $0) }
        
        let finalizedSuccess = finalizedTransfer
            .filterSuccess()
            .map{ ApiResult.success(withData: $0) }
        
        return Observable
            .merge(finalizedSuccess, errors)
            .startWith(ApiResult.loading)
            .shareReplay(1)
        
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
        let offchainRequestTransfer = decryptedKey
            .flatMapLatest{ key in
                self.authManager.offchainRequestTransfer.request(
                    withData: LWPacketRequestTransfer.Body(requestId: request.requestId, prevTempPrivateKey: key)
                )
            }
            .shareReplay(1)
        
        return offchainRequestTransfer
            .filterSuccess()
            .flatMap{ [weak self] offchainResult -> Observable<ApiResult<LWModelOffchainResult>> in
                guard let `self` = self else{ return Observable.never() }
                return self.finalize(offchainResult: offchainResult, channelAssetId: request.assetId)
            }
            .shareReplay(1)
    }
    
    private func processChannel(withOffchainResult offchainResult: LWModelOffchainResult,
                               transactionType: OffchainTransactionType) -> Observable<ApiResult<LWModelOffchainResult>> {
        
        return processChannel(
            transaction: offchainResult.transactionHex,
            transferId: offchainResult.transferId,
            transactionType: transactionType
        )
    }
    
    private func processChannel(transaction: String, transferId: String,
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
    
    private func finalizeTransfer(withOffchainResult offchainResult: LWModelOffchainResult,
                                 channelAsset: String) -> Observable<ApiResult<LWModelOffchainResult>>  {
        
        return finalizeTransfer(
            transaction: offchainResult.transactionHex,
            transferId: offchainResult.transferId,
            channelAsset: channelAsset
        )
    }
    
    private func finalizeTransfer(transaction: String, transferId: String,
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
