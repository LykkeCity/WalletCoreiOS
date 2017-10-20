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
    
    public init(
        authManager: LWRxAuthManager,
        privateKeyManager: LWPrivateKeyManager,
        keychainManager: LWKeychainManager
    ) {
        self.authManager = authManager
        self.privateKeyManager = privateKeyManager
        self.keychainManager = keychainManager
    }
    
    public func trade(amount: Decimal, asset: LWAssetModel, forAsset: LWAssetModel) {
        
        let channelAsset = amount > 0 ? forAsset : asset
    
        let channelKeyObservable =
            authManager.offchainChannelKey.request(forAsset: channelAsset.identity)
        
        let decryptedKey = channelKeyObservable
            .decryptKey(withKeyManager: privateKeyManager)
            .replaceNilWith(withKeyChainManager: keychainManager, forAsset: channelAsset)
        
        let tradeObservable = decryptedKey
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
            .subscribe(onNext: {_ in })
    }
}

fileprivate extension ObservableType where Self.E == LWModelOffchainResult {
    
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
    func replaceNilWith(withKeyChainManager keychainManager: LWKeychainManager, forAsset asset: LWAssetModel) -> Observable<String> {
        return map{key in
            guard let key = key else {
                return keychainManager.offchainLastPrivateKey(forAsset: asset.identity)
            }
            
            return key
        }
    }
}
