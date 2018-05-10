//
//  PieChartCenter.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 6/9/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit

@IBDesignable
class PieChartCenter: UIView {

    @IBOutlet weak var currencyName: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet var view: UIView!
    @IBOutlet weak var addMoneyButton: UIButton!
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)!
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib("PieChartCenter")
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }

}
