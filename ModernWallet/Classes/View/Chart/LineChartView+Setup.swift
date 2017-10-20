//
//  LineChartView+Setup.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 7/19/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import Charts

extension LineChartView {
    
    /// Setup line chart view according Lykke design
    func setup() {
        legend.enabled = false
        chartDescription = nil
        drawBordersEnabled = false
        drawGridBackgroundEnabled = false
        drawMarkers = false
        
        leftAxis.enabled = false
        rightAxis.enabled = false
        xAxis.enabled = false
    }
}
