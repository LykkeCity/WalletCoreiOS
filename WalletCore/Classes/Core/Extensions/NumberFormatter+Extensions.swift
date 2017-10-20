//
//  NumberFormatter+Extensions.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/19/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation

public extension NumberFormatter {
    
    public static let instance: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = ""
        formatter.currencySymbol = ""
        
        return formatter
    }()
    
    public static let percentInstanceWithSign: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.negativePrefix = "-"
        formatter.positivePrefix = "+"
        formatter.negativeSuffix = "%"
        formatter.positiveSuffix = "%"
        
        return formatter
    }()
    
    public static let percentInstance: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.negativePrefix = "-"
        formatter.negativeSuffix = "%"
        formatter.positiveSuffix = "%"
        
        return formatter
    }()

    public static let percentInstancePerise: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 6
        formatter.negativePrefix = "-"
        formatter.negativeSuffix = "%"
        formatter.positiveSuffix = "%"
        
        return formatter
    }()
    
    public static func currencyInstance(accuracy: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = ""
        formatter.currencySymbol = ""
        formatter.minimumFractionDigits = accuracy
        formatter.maximumFractionDigits = accuracy
        
        return formatter
    }
}
