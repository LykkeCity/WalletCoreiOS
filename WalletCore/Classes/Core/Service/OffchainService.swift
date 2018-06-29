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
    
    public typealias PendingRequests = (succeeded: [LWModelOffchainResult], failed: Int)
    
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
            .request(baseAsset: asset, quotingAsset: forAsset)
        
        //1. get channel key for asset
        let offchainChannelKey = dependency.authManager.offchainChannelKey.request(withParams: channelAsset.identity)
        
        //decrypt chanel key with user key
        let decryptedKey = offchainChannelKey
            .filterSuccess()
            .decryptKey(withKeyManager: dependency.privateKeyManager)
            .replaceNilWithLastPrivateKey(keyChainManager: dependency.keychainManager, forAssetId: channelAsset.identity)
        
        //2. request offchain trading
        let offchainTrade = Observable
            .zip(decryptedKey, pair.filterSuccess().filterNil())
            .map{decryptedKey, pair in LWPacketOffchainTrade.Body(
                asset: asset.identity,
                assetPair: pair.identity,
                prevTempPrivateKey: decryptedKey,
                volume: amount
            )}
            .flatMapLatest{ [dependency] body in
                return dependency.authManager.offchainTrade.request(withParams: body)
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
    
    public func cashOutSwift(amount: Decimal, fromAsset asset: LWAssetModel, toBank bankName: String,
                             iban: String, bic: String, accountHolder: String, accountHolderAddress: String, accountHolderCountry: String, accountHolderCountryCode: String, accountHolderZipCode: String, accountHolderCity: String) -> Observable<ApiResult<LWModelOffchainResult>> {
        
        //1. get channel key for asset
        let offchainChannelKey = dependency.authManager.offchainChannelKey.request(withParams: asset.identity)
        
        //decrypt chanel key with user key
        let decryptedKey = offchainChannelKey
            .filterSuccess()
            .decryptKey(withKeyManager: dependency.privateKeyManager)
            .replaceNilWithLastPrivateKey(keyChainManager: dependency.keychainManager, forAssetId: asset.identity)
        
        //2. request offchain operation
        let offchainCashOutSwift = decryptedKey
            .map { decryptedKey in LWPacketOffchainCashOutSwift.Body(
                amount: amount,
                asset: asset.identity,
                bankName: bankName,
                iban: iban,
                bic: bic,
                accountHolder: accountHolder,
                accountHolderAddress: accountHolderAddress,
                accountHolderCountry: accountHolderCountry,
                accountHolderCountryCode: accountHolderCountryCode,
                accountHolderZipCode: accountHolderZipCode,
                accountHolderCity: accountHolderCity,
                prevTempPrivateKey: decryptedKey)}
            .flatMapLatest { [dependency] data in
                return dependency.authManager.offchainCashOutSwift.request(withParams: data)
            }
            .shareReplay(1)
        
        //3. create channel if needed and finalize transfer
        let finalizedTrade = offchainCashOutSwift
            .filterSuccess()
            .finalize(withChannelAssetId: asset.identity, dependency: dependency)
        
        //Merge all error streams into one
        let errors = Observable
            .merge(
                offchainChannelKey.filterError(),
                offchainCashOutSwift.filterError(),
                finalizedTrade.filterError()
            ).map{
                ApiResult<LWModelOffchainResult>.error(withData: $0)
            }
        
        let finalResult = finalizedTrade.filter{ $0.isSuccess }
        
        return Observable
            .merge(errors, finalResult)
            .startWith(ApiResult.loading)
            .shareReplay(1)
    }
    
    public func finalizePendingRequests(refresh: Observable<Void>, maxProcessingTime: RxTimeInterval) -> Observable<PendingRequests> {
        return refresh.processPendingRequests(maxProcessingTime: maxProcessingTime, dependency: dependency)
    }
}

fileprivate typealias ChanelKeyAndRequest = (channelKey: LWModelOffchainChannelKey, request: LWModelOffchainRequest)
fileprivate typealias RequestAndResult = (request: LWModelOffchainRequest, result: LWModelOffchainResult)

// MARK: Rx Void
fileprivate extension ObservableType where Self.E == Void {
    
    func processPendingRequests(maxProcessingTime: RxTimeInterval, dependency: OffchainService.Dependency)
        -> Observable<OffchainService.PendingRequests> {
            
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
        return requests
            .filterSuccess()
            .filterEmpty()
            .processPendingRequests(withDependency: dependency, maxProcessingTime: maxProcessingTime)
            .reduceToPendingRequests()
            .shareReplay(1)
    }
}

// MARK: Rx  ApiResult<LWModelOffchainResult>
fileprivate extension ObservableType where Self.E == ApiResult<LWModelOffchainResult> {
    
    /// Reduce processed requests into a OffchainService.PendingRequests
    ///
    /// - Returns: Observable of OffchainService.PendingRequests
    func reduceToPendingRequests() -> Observable<OffchainService.PendingRequests> {
        return reduce(OffchainService.PendingRequests(succeeded: [], failed: 0)) {acumulated, apiResult -> OffchainService.PendingRequests in
            var acumulated = acumulated
            
            if apiResult.isLoading {
                return acumulated
            }
            
            if let offchainResult = apiResult.getSuccess() {
                acumulated.succeeded.append(offchainResult)
            } else {
                acumulated.failed += 1
            }
            
            return acumulated
        }
    }
}

// MAR: Rx [LWModelOffchainRequest]
fileprivate extension ObservableType where Self.E == [LWModelOffchainRequest] {
    
    /// Start processing pending requests in random order.Max time for running requests is maxProcessingTime sec.
    ///
    /// - Parameter dependency: Dependency
    /// - Returns: Observable of finalized/failed pending requests
    func processPendingRequests(withDependency dependency: OffchainService.Dependency, maxProcessingTime: RxTimeInterval)
        -> Observable<ApiResult<LWModelOffchainResult>> {
            
        return flatMap{ requests -> Observable<ApiResult<LWModelOffchainResult>> in
            Observable
                //process pending request in a sequence
                .concat(
                    requests
                        .shuffled() // randomize array so there is a better chance to process all of them
                        .map{ Observable.just($0) }
                        .flatMap{ $0.finalizePendingRequest(dependency) }
                )
                //stop making request if it takes more than 20 seconds
                .takeUntil(
                    Observable<Int>
                        .interval(maxProcessingTime, scheduler: MainScheduler.instance)
                        .take(1)
                )
        }
    }
}

// MARK: Rx RequestAndResult
fileprivate extension ObservableType where Self.E == RequestAndResult {
    func finalize(_ dependency: OffchainService.Dependency) -> Observable<ApiResult<LWModelOffchainResult>> {
        return
            flatMap{ data in
                Observable<LWModelOffchainResult>
                    .just(data.result)
                    .finalize(withChannelAssetId: data.request.assetId, dependency: dependency)
            }
            .shareReplay(1)
    }
}

// MARK: Rx LWModelOffchainResult
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
                    withParams: LWPacketOffchainProcessChannel.Body(
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
                
                return dependency.authManager.offchainFanilazeTransfer.request(withParams: LWPacketOffchainFinalizetransfer.Body(
                    transferId: result.transferId,
                    clientRevokePubKey: publicKey,
                    clientRevokeEncryptedPrivateKey: dependency.privateKeyManager.encryptExternalWalletKey(wif),
                    signedTransferTransaction: signedTransaction
                ))
            }
            .shareReplay(1)
    }
}

// MARK: LWModelOffchainRequest
fileprivate extension ObservableType where Self.E == LWModelOffchainRequest {
    
    func finalizePendingRequest(_ dependency: OffchainService.Dependency) -> Observable<ApiResult<LWModelOffchainResult>> {
        
        //1. get channel key and decrypt channel key
        let offchainChannelKey =
            flatMapLatest{ request in
                dependency.authManager.offchainChannelKey
                    .request(withParams: request.assetId)
                    .map{ (chanelKey: $0, request: request) }
            }
            .shareReplay(1)
        
        let decryptedKey = offchainChannelKey
            .map{ data -> ChanelKeyAndRequest? in
                guard let channelKey = data.chanelKey.getSuccess() else { return nil }
                return (channelKey: channelKey, request: data.request)
            }
            .filterNil()
            .flatMapLatest{ (data: ChanelKeyAndRequest) in
                Observable
                    .just(data.channelKey)
                    .decryptKey(withKeyManager: dependency.privateKeyManager)
                    .replaceNilWithLastPrivateKey(keyChainManager: dependency.keychainManager, forAssetId: data.request.assetId)
                    .map{ (decryptedKey: $0, request: data.request) }
            }
            .shareReplay(1)

        //2. Send request transfer
        let offchainRequestTransfer = decryptedKey
            .flatMapLatest{ data in
                dependency.authManager.offchainRequestTransfer
                    .request(withParams: LWPacketRequestTransfer.Body(requestId: data.request.requestId, prevTempPrivateKey: data.decryptedKey))
                    .map{ (request: data.request, result: $0) }
            }
            .shareReplay(1)
        
        //3. Finalize transfer
        let finalizeTransfer = offchainRequestTransfer
            .map{ data -> RequestAndResult? in
                guard let result = data.result.getSuccess() else { return nil }
                return (request: data.request, result: result)
            }
            .filterNil()
            .finalize(dependency)
        
        let errors = Observable
            .merge(
                offchainChannelKey.map{ $0.chanelKey }.filterError(),
                offchainRequestTransfer.map{ $0.result }.filterError(),
                finalizeTransfer.filterError()
            )
            .map{ ApiResult<LWModelOffchainResult>.error(withData: $0) }
        
        return Observable
            .merge(errors, finalizeTransfer.filter{ $0.isSuccess })
            .startWith(ApiResult.loading)
    }
}

// MARK: Rx LWModelOffchainChannelKey
fileprivate extension ObservableType where Self.E == LWModelOffchainChannelKey {
    func decryptKey(withKeyManager keyManager: LWPrivateKeyManager) -> Observable<String?> {
        return map{ offchainKey -> String? in
            guard let encryptedKey = offchainKey.key else { return nil }
            return keyManager.decryptExternalWalletKey(encryptedKey)
        }
    }
}

// MARK: Rx String?
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

