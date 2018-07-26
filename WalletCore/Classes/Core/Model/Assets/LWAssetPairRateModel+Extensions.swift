//
//  LWAssetPairRateModel+Extensions.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/21/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation

extension Array where Element == LWAssetPairRateModel {
    func find(byPair pair: String?) -> LWAssetPairRateModel? {
        return first {$0.identity ?? "" == pair}
    }
}
