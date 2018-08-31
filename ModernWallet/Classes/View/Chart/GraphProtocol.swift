//
//  GraphProtocol.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 7/18/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

protocol GraphProtocol {
    
    var periodButtonsArray: [PeriodButton] {get set}
    var linearGraphViewP: TradingLinearGraphViewTest {get set}
    var changeLabelP: UILabel {get set}
    var periodsButtonsViewP: UIView {get set}
    var graphViewModelP: GraphDataViewModel {get set}
    var disposeBagP: DisposeBase {get set}
    
    
    func updateSelectedButton (period: LWGraphPeriodModel)
    func updateGraph(graphData: LWPacketGraphData)
    mutating func updatePeriodButtons(periodArray: [LWGraphPeriodModel])
    
}

extension GraphProtocol  where Self: UIViewController {
    
    func updateSelectedButton(period: LWGraphPeriodModel) {
        periodButtonsArray.forEach{button in
            button.isSelected = button.period?.name == period.name
        }
    }
    
    func updateGraph(graphData: LWPacketGraphData) {
        linearGraphViewP.changes = graphData.graphValues
        linearGraphViewP.setNeedsDisplay()
        changeLabelP.text = String(format: "%f%%", graphData.percentChange.floatValue)
    }
    
    
    mutating func updatePeriodButtons(periodArray: [LWGraphPeriodModel]) {
        
        let width : CGFloat = (self.view.bounds.size.width - 20) / CGFloat(periodArray.count)
        var index = 0
        
        for period in periodArray {
            
            let button = PeriodButton.init(type: UIButtonType.custom)
            button.period = period
            
            button.frame = CGRect(x:width*CGFloat(index), y: 0, width: width, height: periodsButtonsViewP.bounds.size.height)
            button.titleLabel?.font = UIFont(name: "Geomanist-Book", size: 14)
            button.setTitle(period.value, for: .normal)
            button.setTitleColor(UIColor.init(r: 255, g: 255, b: 255, a: 100), for: .normal)
            button.setTitleColor(UIColor.white, for: .selected)
            
            button.rx.tap
                .map{period}
                .bind(to: graphViewModelP.selectedPeriod)
                .disposed(by: disposeBagP as! DisposeBag)
            
            periodsButtonsViewP.addSubview(button)
            periodButtonsArray.append(button)
            index += 1
            
            if button.period?.name == self.graphViewModelP.selectedPeriod.value?.name {
                button.isSelected = true
            }
        }
    }
    
    
}

class PeriodButton: UIButton {
    var period: LWGraphPeriodModel?
}
