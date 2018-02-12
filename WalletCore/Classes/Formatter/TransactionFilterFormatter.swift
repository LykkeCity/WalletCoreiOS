//
//  TransactionFilterFormatter.swift
//  AFNetworking
//
//  Created by Lyubomir Marinov on 6.02.18.
//

import Foundation
import RxSwift
import RxCocoa

public protocol TransactionFilterFormatterProtocol {
    func formatUIElement(withDate date: Date, andFormat format: String) -> String
}

public extension TransactionFilterFormatterProtocol {
    func formatUIElement(withDate date: Date, andFormat format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current

        return "\(formatter.string(from: date)) "
    }
}

public class TransactionFilterFormatter: TransactionFilterFormatterProtocol {
    public static let instance = TransactionFilterFormatter()
}
