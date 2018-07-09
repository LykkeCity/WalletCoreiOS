//
//  Date+Extension.swift
//  WalletCore
//
//  Created by Ivan Stoykov on 9.07.18.
//

import Foundation

extension Date {
    func isBefore(date: Date) -> Bool {
        return self.compare(date) != ComparisonResult.orderedDescending
    }
}
