//
//  NSDate+CalculateDifference.swift
//  WalletCore
//
//  Created by Georgi Stanev on 28.03.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation

extension Date {

    /// Calculate difference between dates in seconds
    ///
    /// - Parameter date: Date to compare to
    /// - Returns: Difference in seoncs
    func calculateDifference(toDate date: Date) -> Int {
        let calendar = NSCalendar.current
        var compos: Set<Calendar.Component> = Set<Calendar.Component>()
        compos.insert(.second)
        compos.insert(.minute)

        let difference = calendar.dateComponents(compos, from: self, to: date)
        let differenceMinute = difference.minute ?? 0
        let differenceInSeconds = difference.second ?? 0

        return differenceMinute * 60 + differenceInSeconds
    }
}
