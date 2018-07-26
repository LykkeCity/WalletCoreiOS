//
//  LWModelOffchainResult.swift
//  WalletCore
//
//  Created by Georgi Stanev on 10/19/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit

public struct LWModelOffchainResult {
    public let transferId: String
    public let transactionHex: String
    public let operationResult: Int //'Transfer', 'CreateChannel', 'ClientCommitment
    public let order: LWModelOffchainOrder?

    init(withJSON json: [AnyHashable: Any]) {
        self.transferId = json["TransferId"] as? String ?? ""
        self.transactionHex = json["TransactionHex"] as? String ?? ""
        self.operationResult = json["OperationResult"] as! Int

        if let orderJson = json["Order"] as? [AnyHashable: Any] {
            self.order = LWModelOffchainOrder(withJSON: orderJson)
        } else {
            self.order = nil
        }
    }
}
