//
//  String+Extensions.swift
//  WalletCore
//
//  Created by Vasil Garov on 10/13/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation

public extension String {
    var decimalValue: Decimal? {
        return Decimal(string: replaceDecimalSeparator())
    }
    
    func replaceDecimalSeparator(with: String = ".") -> String {
        let decimalSeparator = Locale.current.decimalSeparator ?? ""
        return replacingOccurrences(of: decimalSeparator, with: with)
    }
    
    func replaceDotWithDecimalSeparator() -> String {
        let decimalSeparator = Locale.current.decimalSeparator ?? ""
        return replacingOccurrences(of: ".", with: decimalSeparator)
    }
    
    func removeGroupingSeparator() -> String {
        let groupingSeparator = Locale.current.groupingSeparator ?? ""
        return replacingOccurrences(of: groupingSeparator, with: "")
    }
}
