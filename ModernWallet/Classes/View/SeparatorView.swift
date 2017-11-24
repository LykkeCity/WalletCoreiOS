//
//  SeparatorView.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 7/17/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit

@IBDesignable
class SeparatorView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        buildView()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 100.0, height: 2.0)
    }
    
    // MARK: - Private
    
    private func buildView() {
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        let blackView = UIView()
        blackView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3)
        blackView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        var viewFrame = bounds
        viewFrame.size.height = 1.0 / UIScreen.main.scale
        blackView.frame = viewFrame
        addSubview(blackView)
        
        let whiteView = UIView()
        whiteView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3)
        whiteView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        viewFrame.origin.y = bounds.height - viewFrame.height
        whiteView.frame = viewFrame
        addSubview(whiteView)
    }

}
