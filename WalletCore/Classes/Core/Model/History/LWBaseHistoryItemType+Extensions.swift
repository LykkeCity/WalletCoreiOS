//
//  LWBaseHistoryItemType+localizedString.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/20/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import UIKit

extension LWBaseHistoryItemType {
    var localizedString: String {
        let volume = Double(self.volume ?? 00)
        
        switch historyType {
            case .trade: return volume > 0 ? Localize("transaction.newDesign.tradeIn") : Localize("transaction.newDesign.tradeOut")
            case .cashInOut: return volume > 0 ? Localize("transaction.newDesign.cashIn") : Localize("transaction.newDesign.cashOut")
            case .transfer: return volume > 0 ? Localize("transaction.newDesign.transferIn") : Localize("transaction.newDesign.transferOut")
            case .settle: return Localize("history.cell.settle")
        }
    }
    
    func asImage() -> UIImage? {
        let volume = Double(self.volume ?? 00)
        
        switch historyType {
            case .trade: return #imageLiteral(resourceName: "transactionBuy")
            case .cashInOut: return volume < 0 ? #imageLiteral(resourceName: "transactionSend") : #imageLiteral(resourceName: "transactionReceive")
            case .transfer: return #imageLiteral(resourceName: "lykkeDebitCardCurrency")
            default: return nil
        }
    }
}
