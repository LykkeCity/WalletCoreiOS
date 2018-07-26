//
//  DateFormatter+Extensions.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/19/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation

public extension DateFormatter {
    public static let mediumStyle: DateFormatter = {
        let formatter = DateFormatter()

        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        return formatter
    }()
}
