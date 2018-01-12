//
//  TransactionFormatter.swift
//  WalletCore
//
//  Created by Georgi Stanev on 12.01.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation

public protocol TransactionFormatterProtocol {
    func format(date: Date) -> String
    func formatAmount(volume: Optional<Decimal>, asset: Optional<LWAssetModel>) -> String
    func formatDisplayName(asset: LWAssetModel?, item: LWBaseHistoryItemType) -> String
}

public extension TransactionFormatterProtocol {
    func format(date: Date) -> String {
        return DateFormatter.mediumStyle.string(from: date)
    }
    
    func formatAmount(volume: Decimal?, asset: LWAssetModel?) -> String {
        guard let volume = volume else { return Localize("newDesign.notAvailable") }
        
        let volumeString = volume.convertAsCurrency(
            code: asset?.name ?? "",
            symbol: "",
            accuracy: Int(asset?.accuracy ?? 2)
        )
        
        return volume > 0 ? "+\(volumeString)" : volumeString
    }
    
    func formatDisplayName(asset: LWAssetModel?, item: LWBaseHistoryItemType) -> String {
        let assetName = asset?.displayFullName ?? ""
        return "\(item.localizedString) \(assetName)"
    }
}

public class TransactionFormatterDefault: TransactionFormatterProtocol {
    public static let instance = TransactionFormatterDefault()
}
