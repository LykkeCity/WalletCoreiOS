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
    
    public func trade(amount: Decimal,
                      asset: LWAssetModel,
                      forAsset: LWAssetModel) -> Observable<ApiResult<LWModelOffchainResult>> {
        
        let channelAsset = amount > 0 ? forAsset : asset
    
        //1. get channel key for asset
        let offchainChannelKey = authManager.offchainChannelKey.request(forAsset: channelAsset.identity)
        
        //decrypt chanel key with user key
        let decryptedKey = offchainChannelKey
            .decryptKey(withKeyManager: privateKeyManager)
            .replaceNilWithLastPrivateKey(keyChainManager: keychainManager, forAsset: channelAsset)
        
        //2. request offchain trading
        let offchainTrade = decryptedKey
            .map{decryptedKey in
                return LWPacketOffchainTrade.Body(
                    asset: asset.identity,
                    assetPair: asset.getPairId(withAsset: forAsset),
                    prevTempPrivateKey: decryptedKey,
                    volume: amount
                )
            }
            .flatMapLatest{[weak self] body in
                return self?.authManager.offchainTrade.request(withData: body) ?? Observable.never()
            }
            .shareReplay(1)
        
        //3. request chanel processing if trading returns success
        let offchainProcessChanel = offchainTrade
            .filterSuccess()
            .flatMapLatest{[weak self] (offchainResult: LWModelOffchainResult) -> Observable<ApiResult<LWModelOffchainResult>> in
                guard let `self` = self else {return Observable.never()}
                return self.processChannel(transaction: offchainResult.transactionHex, transferId: offchainResult.transferId, transactionType: .cashIn)
            }
            .shareReplay(1)
        
        //4. finalize transfer if chanel processing is sucessful
        let offchainFinalizeTransfer = offchainProcessChanel
            .filterSuccess()
            .flatMapLatest{[weak self] (offchainResult: LWModelOffchainResult) -> Observable<ApiResult<LWModelOffchainResult>> in
                guard let `self` = self else {return Observable.never()}
                return self.finalizeTransfer(
                    transaction: offchainResult.transactionHex,
                    transferId: offchainResult.transferId,
                    channelAsset: channelAsset.identity
                )
            }
            .shareReplay(1)
        
        //Merge all error streams into one
        let errors = Observable.merge(
            offchainChannelKey.filterError(),
            offchainTrade.filterError(),
            offchainProcessChanel.filterError(),
            offchainFinalizeTransfer.filterError()
        ).map{ApiResult<LWModelOffchainResult>.error(withData: $0)}
        
        let finalResult = offchainFinalizeTransfer
            .filterSuccess()
            .map{ApiResult<LWModelOffchainResult>.success(withData: $0)}
        
        let isLoading = offchainChannelKey.isLoading().filter{$0}.map{_ in ApiResult<LWModelOffchainResult>.loading}
        
        return Observable
            .merge(isLoading, errors, finalResult)
            .shareReplay(1)
            .debug("GG: trade", trimOutput: false)
    }
    
    public func processChannel(
        transaction: String,
        transferId: String,
        transactionType: OffchainTransactionType
    ) -> Observable<ApiResult<LWModelOffchainResult>> {
                
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
    
    
    public func finalizeTransfer(transaction: String, transferId: String, channelAsset: String) -> Observable<ApiResult<LWModelOffchainResult>>  {
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

fileprivate extension ObservableType where Self.E == ApiResult<LWModelOffchainChannelKey> {
    func decryptKey(withKeyManager keyManager: LWPrivateKeyManager) -> Observable<String?> {
        return filterSuccess()
            .map{$0.key}
            .map{encryptedKey -> String? in
                return keyManager.decryptExternalWalletKey(encryptedKey)
            }
    }
}

fileprivate extension ObservableType where Self.E == String? {
    func replaceNilWithLastPrivateKey(keyChainManager keychainManager: LWKeychainManager, forAsset asset: LWAssetModel) -> Observable<String> {
        return map{key in
            guard let key = key else {
                return keychainManager.offchainLastPrivateKey(forAsset: asset.identity)
            }
            
            return key
        }
    }
}
