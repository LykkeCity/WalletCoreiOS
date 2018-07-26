//
//  TransactionFormatter.swift
//  WalletCore
//
//  Created by Georgi Stanev on 12.01.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation

public protocol TransactionFormatterProtocol {

    /// Format transaction date
    ///
    /// - Parameter date: Date that will be formatted
    /// - Returns: Formated date
    func format(date: Date) -> String

    /// Format transaction amount
    ///
    /// - Parameters:
    ///   - volume: Amount that will be formatted
    ///   - asset: Transaction asset
    /// - Returns: Formatted amount
    func formatAmount(volume: Decimal?, asset: LWAssetModel?) -> String

    /// Format asset && history record into a human readable string
    ///
    /// - Parameters:
    ///   - asset: History asset
    ///   - item: History record
    /// - Returns: Formatted string
    func formatTransactionTitle(asset: LWAssetModel?, item: LWBaseHistoryItemType) -> String
}

public extension TransactionFormatterProtocol {
    /// Format transaction date
    ///
    /// - Parameter date: Date that will be formatted
    /// - Returns: Formated date
    func format(date: Date) -> String {
        return DateFormatter.mediumStyle.string(from: date)
    }

    /// Format transaction amount
    ///
    /// - Parameters:
    ///   - volume: Amount that will be formatted
    ///   - asset: Transaction asset
    /// - Returns: Formatted amount
    func formatAmount(volume: Decimal?, asset: LWAssetModel?) -> String {
        guard let volume = volume else { return Localize("newDesign.notAvailable") }

        let volumeString = volume.convertAsCurrency(
            code: asset?.name ?? "",
            symbol: "",
            accuracy: Int(asset?.accuracy ?? 2)
        )

        return volume > 0 ? "+\(volumeString)" : volumeString
    }

    /// Format asset && history record into a human readable string
    ///
    /// - Parameters:
    ///   - asset: History asset
    ///   - item: History record
    /// - Returns: Formatted string
    func formatTransactionTitle(asset: LWAssetModel?, item: LWBaseHistoryItemType) -> String {
        let assetName = asset?.displayId ?? ""
        return "\(item.localizedString) \(assetName)"
    }
}

public class TransactionFormatter: TransactionFormatterProtocol {
    public static let instance = TransactionFormatter()
}
