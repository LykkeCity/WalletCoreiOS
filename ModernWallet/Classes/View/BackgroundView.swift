//
//  BackgroundView.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 20.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit

@IBDesignable
class BackgroundView: UIView {
    
    private let backgroundImageName = "BlueBackground"
    
    private weak var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackground()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBackground()
    }
    
    override func prepareForInterfaceBuilder() {
        imageView.image = UIImage(named: backgroundImageName, in: Bundle(for: BackgroundView.self), compatibleWith: nil)
        imageView.frame = bounds
    }
    
    override func layoutSubviews() {
        guard let rootView = UIApplication.shared.delegate?.window??.rootViewController?.view else {
            return
        }
        imageView.frame = rootView.convert(rootView.bounds, to: self)
    }

    private func setupBackground() {
        let imageView = UIImageView(image: UIImage(named: backgroundImageName))
        imageView.frame = bounds
        self.imageView = imageView
        if subviews.count == 0 {
            addSubview(imageView)
        }
        else {
            insertSubview(imageView, at: 0)
        }
    }
    
}
