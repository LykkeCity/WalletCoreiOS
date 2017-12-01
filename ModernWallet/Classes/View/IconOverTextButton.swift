//
//  IconOverTextButton.swift
//  ModernMoney
//
//  Created by Nacho Nachev on 30.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit

@IBDesignable
public class IconOverTextButton: UIButton {
    
    @IBInspectable public var spacing: CGFloat = 0.0
    
    public override var intrinsicContentSize: CGSize {
        let imageSize = self.imageSize
        let textSize = self.titleSize
        return CGSize(width: max(imageSize.width, textSize.width),
                      height: imageSize.height + spacing + textSize.height)
    }
    
    public override func contentRect(forBounds bounds: CGRect) -> CGRect {
        var rect = CGRect(origin: bounds.origin, size: intrinsicContentSize)
        rect.origin.x += (bounds.width - rect.width) / 2.0
        rect.origin.y += (bounds.height - rect.height) / 2.0
        return rect
    }
    
    public override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        var rect = CGRect(origin: contentRect.origin, size: titleSize)
        isTitleRectPassedOnce = true
        rect.origin.x += (contentRect.width - rect.width) / 2.0
        rect.origin.y += contentRect.height - rect.height + spacing
        return rect
    }
    
    public override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        var rect = CGRect(origin: contentRect.origin, size: imageSize)
        rect.origin.x += (contentRect.width - rect.width) / 2.0
        return rect
    }

    private var titleSize: CGSize {
        let text = title(for: state) ?? ""
        let font = (isTitleRectPassedOnce ? titleLabel?.font : nil) ?? UIFont.systemFont(ofSize: UIFont.buttonFontSize)
        return text.size(attributes: [NSFontAttributeName: font])
    }
    
    private var imageSize: CGSize {
        return image(for: state)?.size ?? .zero
    }
    
    private var isTitleRectPassedOnce = false

}
