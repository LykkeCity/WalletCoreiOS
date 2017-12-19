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
        rect.size.width = min(rect.width, bounds.width)
        switch contentVerticalAlignment {
        case .center:
            rect.origin.y += (bounds.height - rect.height) / 2.0
        case .bottom:
            rect.origin.y += bounds.height - rect.height
        case .fill:
            rect.size.height = bounds.height
        default:
            break
        }
        let horizontalAlignment: UIControlContentHorizontalAlignment
        if #available(iOS 11.0, *) {
            horizontalAlignment = effectiveContentHorizontalAlignment
        }
        else {
            horizontalAlignment = contentHorizontalAlignment
        }
        switch horizontalAlignment {
        case .center:
            rect.origin.x += (bounds.width - rect.width) / 2.0
        case .right:
            rect.origin.x += bounds.width - rect.width
        case .fill:
            rect.size.width = bounds.width
        default:
            break
        }
        return rect
    }
    
    public override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        var rect = CGRect(origin: contentRect.origin, size: titleSize)
        isTitleRectPassedOnce = true
        rect.size.width = min(rect.width, contentRect.width)
        let horizontalAlignment: UIControlContentHorizontalAlignment
        if #available(iOS 11.0, *) {
            horizontalAlignment = effectiveContentHorizontalAlignment
        }
        else {
            horizontalAlignment = contentHorizontalAlignment
        }
        switch horizontalAlignment {
        case .center:
            rect.origin.x += (contentRect.width - rect.width) / 2.0
        case .right:
            rect.origin.x += contentRect.width - rect.width
        default:
            break
        }
        rect.origin.y += contentRect.height - rect.height
        return rect
    }
    
    public override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        var rect = CGRect(origin: contentRect.origin, size: imageSize)
        rect.size.width = min(rect.width, contentRect.width)
        if contentVerticalAlignment == .fill || contentRect.height < intrinsicContentSize.height {
            rect.size.height = max(contentRect.height - titleRect(forContentRect: contentRect).height - spacing, 0.0)
        }
        let horizontalAlignment: UIControlContentHorizontalAlignment
        if #available(iOS 11.0, *) {
            horizontalAlignment = effectiveContentHorizontalAlignment
        }
        else {
            horizontalAlignment = contentHorizontalAlignment
        }
        switch horizontalAlignment {
        case .center:
            rect.origin.x += (contentRect.width - rect.width) / 2.0
        case .right:
            rect.origin.x += contentRect.width - rect.width
        case .fill:
            rect.size.width = contentRect.width
        default:
            break
        }
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
