//
//  U.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 7/19/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Charts

extension Reactive where Base: UIStackView {
    
    
    /// Graph hint that will show a label above/below the graph highlight/circle
    var graphHint: UIBindingObserver<Base, (value: String, currencyCode:String, highlight: Highlight, isAbove: Bool)> {
        return UIBindingObserver(UIElement: self.base) { view, data in
            
            guard let amauntLabel = view.arrangedSubviews.first as? UILabel else {return}
            guard let currencyShortNameLabel = view.arrangedSubviews.last as? UILabel else {return}
            
            amauntLabel.text = data.value
            amauntLabel.sizeToFit()
            
            currencyShortNameLabel.text = data.currencyCode
            currencyShortNameLabel.sizeToFit()
            
            view.frame = self.getFrame(view: view, highlight: data.highlight, isAbove: data.isAbove)
            
            view.sizeToFit()
        }
    }
    
    private func getFrame(view: Base, highlight: Highlight, isAbove: Bool) -> CGRect {
        let width = view.arrangedSubviews.reduce(view.spacing){$0.0 + $0.1.frame.width}
        let height = view.arrangedSubviews.reduce(0){$0.0 + $0.1.frame.height}
        let y = isAbove ? highlight.yPx + 10 : highlight.yPx + 60
        
        //calculate x
        var x = highlight.xPx - width / 2
        if let maxX = view.superview?.bounds.maxX, highlight.xPx + width / 2 > maxX  {
            x = highlight.xPx - width
        }
        if let minX = view.superview?.bounds.minX, highlight.xPx - width / 2 < minX  {
            x = highlight.xPx
        }
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
