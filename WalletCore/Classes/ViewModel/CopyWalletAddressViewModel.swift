//
//  CopyWalletAddressViewModel
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/4/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class CopyWalletAddressViewModel {
    public let tap: Driver<String>

    public init(tap: Driver<Void>, wallet: Variable<LWPrivateWalletModel?>) {
        self.tap = tap
                .throttle(1)
                .map{wallet.value?.address}
                .filterNil()
    }
}
