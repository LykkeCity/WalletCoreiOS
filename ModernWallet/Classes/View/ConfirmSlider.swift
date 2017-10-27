//
//  ConfirmSlider.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 17.10.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@IBDesignable
class ConfirmSlider: UIControl {
    
    override var isEnabled: Bool {
        didSet {
            let color: CGColor = isEnabled ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6)
            handlerLayer.strokeColor = color
            layer.borderColor = color
        }
    }
    
    var value: Bool {
        get { return handlerLocation == 1 }
        set { handlerLocation = newValue ? 1 : 0 }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override func layoutSubviews() {
        let handlerRect = CGRect(x: handlerLocation * (bounds.width - bounds.height), y: 0, width: bounds.height, height: bounds.height)
        handlerLayer.path = UIBezierPath(ovalIn: handlerRect).cgPath
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 175.0, height: 69.0)
    }
    
    // MARK: - Private
    
    private lazy var handlerLayer: CAShapeLayer! = {
        let handlerLayer = CAShapeLayer()
        handlerLayer.fillColor = nil
        handlerLayer.lineWidth = 1.0
        handlerLayer.strokeColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        return handlerLayer
    }()
    
    fileprivate var handlerLocation: CGFloat = 0.0 {
        didSet {
            let center = CGPoint(x: (bounds.width - bounds.height) * handlerLocation, y: 0.0)
            handlerLayer.position = center
        }
    }
    
    private var gestureStartLocation: CGFloat = 0.0
    
    private func setup() {
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        layer.borderWidth = 1.0
        layer.cornerRadius = bounds.height / 2.0
        layer.masksToBounds = true
        layer.addSublayer(handlerLayer)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(ConfirmSlider.handlePanGesture(_:)))
        gesture.maximumNumberOfTouches = 1
        gesture.delegate = self
        addGestureRecognizer(gesture)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            gestureStartLocation = handlerLocation
        case .ended, .cancelled:
            if handlerLocation > 0.0 && handlerLocation < 1.0 {
                UIView.animate(withDuration: 0.25) {
                    self.handlerLocation = 0.0
                }
            }
        default:
            let xTranslation = gesture.translation(in: self).x
            let location = xTranslation / (bounds.width - bounds.height) + gestureStartLocation
            let oldValue = value
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            handlerLocation = max(0.0, min(1.0, location))
            CATransaction.commit()
            if oldValue != value {
                sendActions(for: .valueChanged)
            }
        }
    }

}

// MARK: - UIGestureRecognizerDelegate
extension ConfirmSlider: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: self)
        let handlerRadius = 0.5 * bounds.height
        let dx = (bounds.width - bounds.height) * handlerLocation + handlerRadius - point.x
        let dy = handlerRadius - point.y
        let distanceFromCenter = sqrt(dx * dx + dy * dy)
        return distanceFromCenter <= handlerRadius
    }
    
}
