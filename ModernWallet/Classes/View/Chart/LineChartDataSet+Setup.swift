//
//  LineChartDataSet+Setup.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 7/19/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import Charts

extension LineChartDataSet {
    
    /// Setup LineChartDataSet according Lykke design
    ///
    /// - Returns: Self
    func setup() -> LineChartDataSet {
        drawIconsEnabled = false
        lineDashLengths = [0.0]
        colors = [UIColor.white]
        circleColors = [UIColor.white]
        lineWidth = 1.0
        circleRadius = 4.0
        drawCircleHoleEnabled = false
        valueFont = UIFont.systemFont(ofSize: 9.0)
        formLineDashLengths = [5.0, 2.5]
        formLineWidth = 1.0
        highlightEnabled = true
        highlightLineWidth = CGFloat(0)
        formSize = 15.0
        valueColors = [UIColor.white]
        if let font = UIFont(name: "GEOMANIST", size: 16) {
            valueFont = font
        }
        
        drawValuesEnabled = false
        
        let gradientColors =  [
            ChartColorTemplates.colorFromString("#00ffffff").cgColor,
            ChartColorTemplates.colorFromString("#3fffffff").cgColor
        ] as CFArray
        
        if let gradient = CGGradient(colorsSpace: nil, colors:gradientColors, locations: nil) {
            fillAlpha = CGFloat(7.0)
            fill = Fill.fillWithLinearGradient(gradient, angle: CGFloat(90.0))
            drawFilledEnabled = true
        }
        
        return self
    }
}
