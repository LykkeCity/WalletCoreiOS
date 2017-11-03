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
    
    public typealias Dependency = (
        authManager: LWRxAuthManager,
        privateKeyManager: LWPrivateKeyManager,
        keychainManager: LWKeychainManager,
        transactionManager: LWTransactionManager
    )
    
    public static let instance: OffchainService = {
        return OffchainService(OffchainService.Dependency(
            authManager: LWRxAuthManager.instance,
            privateKeyManager: LWPrivateKeyManager.shared(),
            keychainManager: LWKeychainManager.instance(),
            transactionManager: LWTransactionManager.shared()
        ))
    }()
    
    private let dependency: Dependency
    
    public init(_ dependency: Dependency) {
        self.dependency = dependency
    }
    
    public func trade(amount: Decimal, asset: LWAssetModel, forAsset: LWAssetModel) -> Observable<ApiResult<LWModelOffchainResult>> {
        let channelAsset = amount > 0 ? forAsset : asset
        
        let pair = dependency.authManager.assetPairs
            .requestAssetPair(baseAsset: asset, quotingAsset: forAsset)
        
        //1. get channel key for asset
        let offchainChannelKey = dependency.authManager.offchainChannelKey.request(forAsset: channelAsset.identity)
        
        //decrypt chanel key with user key
        let decryptedKey = offchainChannelKey
            .filterSuccess()
            .decryptKey(withKeyManager: dependency.privateKeyManager)
            .replaceNilWithLastPrivateKey(keyChainManager: dependency.keychainManager, forAssetId: channelAsset.identity)
        
        //2. request offchain trading
        let offchainTrade = Observable
            .zip(decryptedKey, pair.filterSuccess().filterNil())
            .map{decryptedKey, pair in LWPacketOffchainTrade.Body(
                asset: channelAsset.identity,
                assetPair: pair.identity,
                prevTempPrivateKey: decryptedKey,
                volume: amount
            )}
            .flatMapLatest{ [dependency] body in
                return dependency.authManager.offchainTrade.request(withData: body)
            }
            .shareReplay(1)
        
        //3. create channel if needed and finalize transfer
        let finalizedTrade = offchainTrade
            .filterSuccess()
            .finalize(withChannelAssetId: channelAsset.identity, dependency: dependency)
        
        //Merge all error streams into one
        let errors = Observable
            .merge(
                offchainChannelKey.filterError(),
                offchainTrade.filterError(),
                finalizedTrade.filterError(),
                pair.filterSuccess().filter{ $0 == nil }.map{ _ in ["Message": "There is no asset pair for your request."]}
            ).map{
                ApiResult<LWModelOffchainResult>.error(withData: $0)
            }
        
        let finalResult = finalizedTrade.filter{ $0.isSuccess }
        
        return Observable
            .merge(errors, finalResult)
            .startWith(ApiResult.loading)
            .shareReplay(1)
    }
    
    public func finalizePendingRequests(refresh: Observable<Void>) -> Disposable {
        return refresh
            .processPendingRequests(dependency)
            .subscribe()
    }
}

fileprivate extension ObservableType where Self.E == Void {
    func processPendingRequests(_ dependency: OffchainService.Dependency) -> Observable<Void> {
        //1. get pending actions
        let pendingActions =
            flatMapLatest{ [dependency] _ in dependency.authManager.checkPendingActions.request() }
            .shareReplay(1)
        
        //2. get requests if there are pending offchain requests
        let requests = pendingActions
            .filterSuccess()
            .filter{ $0.hasOffchainRequests }
            .flatMapLatest{ [dependency] _ in dependency.authManager.offchainRequests.request() }
            .shareReplay(1)
        
        // Filter first request and subscribe itself until all requests get finalized
        return requests.filterSuccess()
            .map{ $0.randomElement }
            .filterNil()
            .finalizePendingRequest(dependency)
            .filterSuccess()
            .flatMap{ _ in
                Observable<Void>.just(Void()).processPendingRequests(dependency)
            }
    }
}

fileprivate extension ObservableType where Self.E == (request: LWModelOffchainRequest, result: LWModelOffchainResult) {
    func finalize(_ dependency: OffchainService.Dependency) -> Observable<ApiResult<LWModelOffchainResult>> {
        return flatMap{ data in
            return Observable<LWModelOffchainResult>
                .just(data.result)
                .finalize(withChannelAssetId: data.request.assetId, dependency: dependency)
        }
    }
}

fileprivate extension ObservableType where Self.E == LWModelOffchainResult {
    func finalize(withChannelAssetId channelAssetId: String, dependency: OffchainService.Dependency) -> Observable<ApiResult<LWModelOffchainResult>> {
        
        //If channel doesn't exist first create it (if oprerationResult == 1) otherwise just use given offchainResult
        let createdChannel =
            filter{ $0.operationResult == 1 }
            .processChannel(withTransactionType: .createChannel, dependency: dependency)
        
        let reuseChannel =
            filter{ $0.operationResult == 0 }
            .map{ ApiResult.success(withData: $0) }
        
        let processedChannel = Observable.merge(createdChannel, reuseChannel)
        
        //Merge request transfer with result 0 and processed channel and finalize transfer
        let finalizedTransfer = processedChannel
            .filterSuccess()
            .finalizeTransfer(withChannelAsset: channelAssetId, dependency: dependency)
        
        //merge errors from both requests
        let errors = Observable
            .merge(processedChannel.filterError(), finalizedTransfer.filterError())
            .map{ ApiResult<LWModelOffchainResult>.error(withData: $0) }
        
        let finalizedSuccess = finalizedTransfer.filter{ $0.isSuccess }
        
        return Observable
            .merge(errors, finalizedSuccess)
            .startWith(.loading)
            .shareReplay(1)
    }
}

fileprivate extension ObservableType where Self.E == LWModelOffchainResult {
    func processChannel(withTransactionType transactionType: OffchainTransactionType,
                        dependency: OffchainService.Dependency) -> Observable<ApiResult<LWModelOffchainResult>> {
        
        return
            flatMap{ result -> Observable<ApiResult<LWModelOffchainResult>> in
                
                guard let signedChannelTransaction = LWTransactionManager.signOffchainTransaction(
                    result.transactionHex,
                    withKey: dependency.privateKeyManager.wifPrivateKeyLykke,
                    type: transactionType
                ) else {
                    return Observable.just(.error(withData: ["signedChannelTransaction": "Chanel transaction can not be signed."]))
                }
                
                return dependency.authManager.offchainProcessChannel.request(
                    withData: LWPacketOffchainProcessChannel.Body(
                        transferId: result.transferId,
                        signedChannelTransaction: signedChannelTransaction
                    )
                )
            }
            .shareReplay(1)
    }
    
    func finalizeTransfer(withChannelAsset channelAsset: String, dependency: OffchainService.Dependency) -> Observable<ApiResult<LWModelOffchainResult>>  {
        
        return
            flatMap{ result -> Observable<ApiResult<LWModelOffchainResult>> in
                guard
                    let key = dependency.privateKeyManager.generateKeyDict(),
                    let wif = key["wif"] as? String,
                    let publicKey = key["publicKey"] as? String
                else {
                    return Observable.just(.error(withData: ["generateKey": "Can not generate key."]))
                }
                
                guard
                    let wifPrivateKeyLykke = dependency.privateKeyManager.wifPrivateKeyLykke,
                    let signedTransaction = LWTransactionManager.signOffchainTransaction(result.transactionHex, withKey: wifPrivateKeyLykke, type: .transfer)
                else {
                    return Observable.just(.error(withData: ["signedTransaction": "Can not sign transaction."]))
                }
                
                return dependency.authManager.offchainFanilazeTransfer.request(withData: LWPacketOffchainFinalizetransfer.Body(
                    transferId: result.transferId,
                    clientRevokePubKey: publicKey,
                    clientRevokeEncryptedPrivateKey: dependency.privateKeyManager.encryptExternalWalletKey(wif),
                    signedTransferTransaction: signedTransaction
                ))
            }
            .shareReplay(1)
    }
}

fileprivate extension ObservableType where Self.E == LWModelOffchainRequest {
    func finalizePendingRequest(_ dependency: OffchainService.Dependency) -> Observable<ApiResult<LWModelOffchainResult>> {
        return
            //1. get channel key and decrypt channel key
            flatMapLatest{ request in
                return dependency.authManager.offchainChannelKey
                    .request(forAsset: request.assetId)
                    .filterSuccess()
                    .decryptKey(withKeyManager: dependency.privateKeyManager)
                    .replaceNilWithLastPrivateKey(keyChainManager: dependency.keychainManager, forAssetId: request.assetId)
                    .map{ (request: request, decryptedKey: $0) }
            }
            //2. Send request transfer
            .flatMapLatest{ data in
                dependency.authManager.offchainRequestTransfer
                    .request(withData: LWPacketRequestTransfer.Body(requestId: data.request.requestId, prevTempPrivateKey: data.decryptedKey))
                    .filterSuccess()
                    .map{ (request: data.request, result: $0) }
            }
            //3. Finalize request
            .finalize(dependency)
            .shareReplay(1)
    }
}

fileprivate extension ObservableType where Self.E == LWModelOffchainChannelKey {
    func decryptKey(withKeyManager keyManager: LWPrivateKeyManager) -> Observable<String?> {
        return map{ offchainKey -> String? in
            guard let encryptedKey = offchainKey.key else { return nil }
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

