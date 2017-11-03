//
//  Array+Extensions.swift
//  WalletCore
//
//  Created by Georgi Stanev on 3.11.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation

extension Array {
    var randomElement: Element?  {
        if isEmpty { return nil }
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
}
