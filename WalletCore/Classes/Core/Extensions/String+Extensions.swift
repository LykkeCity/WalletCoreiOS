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
    
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    private func mod97() -> Int {
        let symbols: [Character] = Array(self)
        let swapped = symbols.dropFirst(4) + symbols.prefix(4)
        
        let mod: Int = swapped.reduce(0) { (previousMod, char) in
            let value = Int(String(char), radix: 36)! // "0" => 0, "A" => 10, "Z" => 35
            let factor = value < 10 ? 10 : 100
            return (factor * previousMod + value) % 97
        }
        
        return mod
    }
    
    func isValidBic() -> Bool {
        return self.matches("^([a-zA-Z]){4}([a-zA-Z]){2}([0-9a-zA-Z]){2}([0-9a-zA-Z]{3})?$")
    }
    
    func isValidIban() -> Bool {
        guard self.count >= 4 else {
            return false
        }
        
        let uppercase = self.uppercased()
        
        guard uppercase.range(of: "^[0-9A-Z]*$", options: .regularExpression) != nil else {
            return false
        }
        
        return (uppercase.mod97() == 1)
    }
}
