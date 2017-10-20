//
//  KYCPhotoPlaceholderView.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 9/19/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit

@IBDesignable
class KYCPhotoPlaceholderView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var photoImage: UIImageView!

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
        view = loadViewFromNib("KYCPhotoPlaceholderView")
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }

}
