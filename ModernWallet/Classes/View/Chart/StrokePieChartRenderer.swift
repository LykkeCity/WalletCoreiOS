//
//  StrokePieChartRenderer.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 6/8/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import Charts

fileprivate class ChartUtils {
    internal struct Math {
        internal static let FDEG2RAD = CGFloat(Double.pi / 180.0)
        internal static let FRAD2DEG = CGFloat(180.0 / Double.pi)
        internal static let DEG2RAD = Double.pi / 180.0
        internal static let RAD2DEG = 180.0 / Double.pi
    }
}

class StrokeChartRenderer: PieChartRenderer {
    override func drawDataSet(context: CGContext, dataSet: IPieChartDataSet) {
        guard
            let chart = chart,
            let animator = animator
            else {return }
        
        var angle: CGFloat = 0.0
        let rotationAngle = chart.rotationAngle
        
        let phaseX = animator.phaseX
        let phaseY = animator.phaseY
        
        let entryCount = dataSet.entryCount
        var drawAngles = chart.drawAngles
        let center = chart.centerCircleBox
        let radius = chart.radius
        let drawInnerArc = chart.drawHoleEnabled && !chart.drawSlicesUnderHoleEnabled
        let userInnerRadius = drawInnerArc ? radius * chart.holeRadiusPercent : 0.0
        
        var visibleAngleCount = 0
        for j in 0 ..< entryCount
        {
            guard let e = dataSet.entryForIndex(j) else { continue }
            if ((abs(e.y) > Double.ulpOfOne))
            {
                visibleAngleCount += 1
            }
        }
        
        let sliceSpace = visibleAngleCount <= 1 ? 0.0 : getSliceSpace(dataSet: dataSet)
        
        context.saveGState()
        
        for j in 0 ..< entryCount
        {
            let sliceAngle = drawAngles[j]
            var innerRadius = userInnerRadius
            
            guard let e = dataSet.entryForIndex(j) else { continue }
            
            // draw only if the value is greater than zero
            if (abs(e.y) > Double.ulpOfOne)
            {
                if !chart.needsHighlight(index: j)
                {
                    let accountForSliceSpacing = sliceSpace > 0.0 && sliceAngle <= 180.0
                    
                    context.setFillColor(dataSet.color(atIndex: j).cgColor)
                    
                    let sliceSpaceAngleOuter = visibleAngleCount == 1 ?
                        0.0 :
                        sliceSpace / (ChartUtils.Math.FDEG2RAD * radius)
                    let startAngleOuter = rotationAngle + (angle + sliceSpaceAngleOuter / 2.0) * CGFloat(phaseY)
                    var sweepAngleOuter = (sliceAngle - sliceSpaceAngleOuter) * CGFloat(phaseY)
                    if sweepAngleOuter < 0.0
                    {
                        sweepAngleOuter = 0.0
                    }
                    
                    let arcStartPointX = center.x + radius * cos(startAngleOuter * ChartUtils.Math.FDEG2RAD)
                    let arcStartPointY = center.y + radius * sin(startAngleOuter * ChartUtils.Math.FDEG2RAD)
                    
                    let path = CGMutablePath()
                    
                    path.move(to: CGPoint(x: arcStartPointX,
                                          y: arcStartPointY))
                    
                    path.addRelativeArc(center: center, radius: radius, startAngle: startAngleOuter * ChartUtils.Math.FDEG2RAD, delta: sweepAngleOuter * ChartUtils.Math.FDEG2RAD)
                    
                    if drawInnerArc &&
                        (innerRadius > 0.0 || accountForSliceSpacing)
                    {
                        if accountForSliceSpacing
                        {
                            var minSpacedRadius = calculateMinimumRadiusForSpacedSlice(
                                center: center,
                                radius: radius,
                                angle: sliceAngle * CGFloat(phaseY),
                                arcStartPointX: arcStartPointX,
                                arcStartPointY: arcStartPointY,
                                startAngle: startAngleOuter,
                                sweepAngle: sweepAngleOuter)
                            if minSpacedRadius < 0.0
                            {
                                minSpacedRadius = -minSpacedRadius
                            }
                            innerRadius = min(max(innerRadius, minSpacedRadius), radius)
                        }
                        
                        let sliceSpaceAngleInner = visibleAngleCount == 1 || innerRadius == 0.0 ?
                            0.0 :
                            sliceSpace / (ChartUtils.Math.FDEG2RAD * innerRadius)
                        let startAngleInner = rotationAngle + (angle + sliceSpaceAngleInner / 2.0) * CGFloat(phaseY)
                        var sweepAngleInner = (sliceAngle - sliceSpaceAngleInner) * CGFloat(phaseY)
                        if sweepAngleInner < 0.0
                        {
                            sweepAngleInner = 0.0
                        }
                        let endAngleInner = startAngleInner + sweepAngleInner
                        
                        path.addLine(
                            to: CGPoint(
                                x: center.x + innerRadius * cos(endAngleInner * ChartUtils.Math.FDEG2RAD),
                                y: center.y + innerRadius * sin(endAngleInner * ChartUtils.Math.FDEG2RAD)))
                        
                        path.addRelativeArc(center: center, radius: innerRadius, startAngle: endAngleInner * ChartUtils.Math.FDEG2RAD, delta: -sweepAngleInner * ChartUtils.Math.FDEG2RAD)
                        
                    }
                    else
                    {
                        if accountForSliceSpacing
                        {
                            let angleMiddle = startAngleOuter + sweepAngleOuter / 2.0
                            
                            let sliceSpaceOffset =
                                calculateMinimumRadiusForSpacedSlice(
                                    center: center,
                                    radius: radius,
                                    angle: sliceAngle * CGFloat(phaseY),
                                    arcStartPointX: arcStartPointX,
                                    arcStartPointY: arcStartPointY,
                                    startAngle: startAngleOuter,
                                    sweepAngle: sweepAngleOuter)
                            
                            let arcEndPointX = center.x + sliceSpaceOffset * cos(angleMiddle * ChartUtils.Math.FDEG2RAD)
                            let arcEndPointY = center.y + sliceSpaceOffset * sin(angleMiddle * ChartUtils.Math.FDEG2RAD)
                            
                            path.addLine(
                                to: CGPoint(
                                    x: arcEndPointX,
                                    y: arcEndPointY))
                        }
                        else
                        {
                            path.addLine(to: center)
                        }
                    }
                    
                    path.closeSubpath()
                    
                    
                    //            context.stroke
                    
                    context.beginPath()
                    context.addPath(path)
                    context.setStrokeColor(UIColor.white.cgColor)
                    context.drawPath(using: .fillStroke)
                    //                    context.fillPath(using: .evenOdd)
                }
            }
            
            angle += sliceAngle * CGFloat(phaseX)
        }
        
        context.restoreGState()
    }
}
