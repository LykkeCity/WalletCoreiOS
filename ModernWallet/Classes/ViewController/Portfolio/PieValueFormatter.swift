//
//  PieValiueFormatter.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 6/9/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import Charts
import WalletCore

class PieValueFormatter: NSObject, IValueFormatter {

    /// Called when a value (from labels inside the chart) is formatted before being drawn.
    ///
    /// For performance reasons, avoid excessive calculations and memory allocations inside this method.
    ///
    /// - returns: The formatted label ready for being drawn
    ///
    /// - parameter value:           The value to be formatted
    ///
    /// - parameter axis:            The entry the value belongs to - in e.g. BarChart, this is of class BarEntry
    ///
    /// - parameter dataSetIndex:    The index of the DataSet the entry in focus belongs to
    ///
    /// - parameter viewPortHandler: provides information about the current chart state (scale, translation, ...)
    ///
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        guard let pieEntry = entry as? PieChartDataEntry else { return "\(value)" }
        if let dataString = pieEntry.data as? String  { return dataString }
        guard let asset = pieEntry.data as? Asset else { return "\(value)" }
        
        let percent = NumberFormatter.percentInstance.string(from: asset.percent as NSNumber) ?? ""
        
        var formattedValue = asset.cryptoCurrency.shortName.components(separatedBy: " ")
        formattedValue.append(percent)

        return formattedValue.joined(separator: "\n")
    }
}
