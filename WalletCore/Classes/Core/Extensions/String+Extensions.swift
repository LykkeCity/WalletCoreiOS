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
    
    func isValidBicOrSwift() -> Bool {
        return self.matches("^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$")
    }
    
    func isValidIban() -> Bool {
        
        let countryCodes = ["AF", "AX", "AL", "DZ", "AS", "AD", "AO", "AI", "AQ", "AG", "AR", "AM", "AW", "AU", "AZ",
                            "BS", "BH", "BD", "BB", "BY", "BE", "BZ", "BJ", "BM", "BT", "BO", "BA", "BW", "BV", "BR",
                            "IO", "BN", "BG", "BF", "BI", "KH", "CM", "CA", "CV", "KY", "CF", "TD", "CL", "CN", "CX",
                            "CC", "CO", "KM", "CG", "CD", "CK", "CR", "CI", "HR", "CU", "CY", "CZ", "DK", "DJ", "DM",
                            "DO", "EC", "EG", "SV", "GQ", "ER", "EE", "ET", "FK", "FO", "FJ", "FI", "FR", "GF", "PF",
                            "TF", "GA", "GM", "GE", "DE", "GH", "GI", "GR", "GL", "GD", "GP", "GU", "GT", "GG", "GN",
                            "GW", "GY", "HT", "HM", "VA", "HN", "HK", "HU", "IS", "IN", "ID", "IR", "IQ", "IE", "IM",
                            "IL", "IT", "JM", "JP", "JE", "JO", "KZ", "KE", "KI", "KP", "KR", "KW", "KG", "LA", "LV",
                            "LB", "LS", "LR", "LY", "LI", "LT", "LU", "MO", "MK", "MG", "MW", "MY", "MV", "ML", "MT",
                            "MH", "MQ", "MR", "MU", "YT", "MX", "FM", "MD", "MC", "MC", "MN", "ME", "MS", "MA", "MZ",
                            "MM", "MA", "NR", "NP", "NL", "AN", "NC", "NZ", "NI", "NE", "NG", "NU", "NF", "MP", "NO",
                            "OM", "PK", "PW", "PS", "PA", "PG", "PY", "PE", "PH", "PN", "PL", "PT", "PR", "QA", "RE",
                            "RO", "RU", "RW", "SH", "KN", "LC", "PM", "VC", "WS", "SM", "ST", "SA", "SN", "RS", "SC",
                            "SL", "SG", "SK", "SI", "SB", "SO", "ZA", "GS", "ES", "LK", "SD", "SR", "SJ", "SZ", "SE",
                            "CH", "SY", "TW", "TJ", "TZ", "TH", "TL", "TG", "TK", "TO", "TT", "TN", "TR", "TM", "TC",
                            "TV", "UG", "UA", "AE", "GB", "US", "UM", "UY", "UZ", "VU", "VE", "VN", "VG", "VI", "WF",
                            "EH", "YE", "ZM", "ZW"]
        
        let startLikeIban = self.matches("^(" + countryCodes.joined(separator: "|") + ")([a-zA-Z0-9])*$")
        
        //If the string is not beginning like an IBAN it's possible to be a US bank account number. The bank account number have to be at least 8 characters at length.
        if !startLikeIban && self.count >= 8 {
            return true
        }
        
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
