//
//  AlertPresenter.swift
//  WalletCore
//
//  Created by Vladimir Dimov on 25.10.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public protocol AlertPresenter {
    func presentAlert() -> Observable<Bool>
}
