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
    
    public func loadWallets() -> Observable<ApiResult<[LWPrivateWalletModel]>> {
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
