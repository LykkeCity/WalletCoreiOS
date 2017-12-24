//
//  LWRxPrivateWalletsManager.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/3/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class LWRxPrivateWalletsManager {
    let manager: LWPrivateWalletsManager
    
    public static let instance = LWRxPrivateWalletsManager()
    
    private init(manager: LWPrivateWalletsManager = LWPrivateWalletsManager.shared()) {
        self.manager = manager
    }
    
    public func loadWallets() -> Observable<ApiResultList<LWPrivateWalletModel>> {
        return Observable.create{[weak self] observer in
            self?.manager.loadWallets{data in
                guard let wallets = (data?.map{$0 as! LWPrivateWalletModel}) else {
                    observer.onNext(.error(withData: [:]))
                    observer.onCompleted()
                    return
                }
                
                observer.onNext(.success(withData: wallets))
                observer.onCompleted()
            }
            
            return Disposables.create {}
        }
        .startWith(.loading)
        .shareReplay(1)
    }
}

public extension ObservableType where Self.E == ApiResultList<LWPrivateWalletModel> {
    public func filterSuccess() -> Observable<[LWPrivateWalletModel]> {
        return
            map{(walletData: ApiResultList<LWPrivateWalletModel>) -> [LWPrivateWalletModel]? in
                guard case let .success(data) = walletData else {return nil}
                return data
            }
            .filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return
            map{(walletData: ApiResultList<LWPrivateWalletModel>) -> Bool in
                guard case .loading = walletData else {return false}
                return true
        }
    }
}
