//
//  SendEmailWithAddressViewModel.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/4/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

open class SendEmailWithAddressViewModel {
    
    public let emailSent: Driver<ApiResult<Void>>
    
    public init(sendObservable: Observable<Void>, wallet: Variable<LWPrivateWalletModel?>, authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        emailSent =
            sendObservable
                .throttle(2, scheduler: MainScheduler.instance)
                .map{wallet.value}
                .filterNil()
                .flatMap{wallet in authManager.emailWalletAddress.requestSendEmail(forWallet: wallet)}
                .asDriver(onErrorJustReturn: .error(withData: [:]))
    }
}
