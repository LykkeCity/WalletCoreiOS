//
//  AssetAmountView.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 10.10.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@IBDesignable
class AssetAmountView: UIView {
    
    @IBInspectable var amountFont: UIFont? {
        get { return amountLabel?.font }
        set {
            amountLabel?.font = newValue
            invalidateIntrinsicContentSize()
        }
    }
    
    @IBInspectable var codeFont: UIFont? {
        get { return codeLabel?.font }
        set {
            codeLabel?.font = newValue
            invalidateIntrinsicContentSize()
        }
    }
    
    @IBInspectable var textColor: UIColor? {
        didSet {
            amountLabel.textColor = textColor
            codeLabel.textColor = textColor
        }
    }
    
    @IBInspectable var spacing: CGFloat {
        get { return stackView.spacing }
        set {
            stackView.spacing = newValue
            invalidateIntrinsicContentSize()
        }
    }
    
    var amount: String? {
        get { return amountLabel?.text }
        set {
            amountLabel?.text = newValue?.trimmingCharacters(in: CharacterSet.whitespaces)
            invalidateIntrinsicContentSize()
        }
    }
    
    var code: String? {
        get { return codeLabel?.text }
        set {
            codeLabel?.text = newValue?.trimmingCharacters(in: CharacterSet.whitespaces)
            invalidateIntrinsicContentSize()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupViews()
    }
    
    override func prepareForInterfaceBuilder() {
        amountLabel.text = "1,234.56"
        codeLabel.text = "XXX"
    }
    
    override var intrinsicContentSize: CGSize {
        var amountText = amountLabel.text ?? "I"
        if amountText == "" {
            amountText = "I"
        }
        let amountSize = amountText.size(attributes: [NSFontAttributeName: amountLabel.font])
        var codeText = codeLabel.text ?? "I"
        if codeText == "" {
            codeText = "I"
        }
        let codeSize = codeText.size(attributes: [NSFontAttributeName: amountLabel.font])
        return CGSize(width: amountSize.width + stackView.spacing + codeSize.width,
                      height: max(amountSize.height, codeSize.height))
    }
    
    // MARK: - Private
    
    private var amountLabel: UILabel!
    
    private var codeLabel: UILabel!
    
    private var stackView: UIStackView!
    
    private func setupViews() {
        backgroundColor = UIColor.clear
        
        amountLabel = UILabel()
        amountLabel.text = " "
        amountLabel.adjustsFontSizeToFitWidth = true
        amountLabel.minimumScaleFactor = 0.5
        amountLabel.font = UIFont(name: "Geomanist-Light", size: 30.0)
        amountLabel.textColor = textColor ?? UIColor.white
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        codeLabel = UILabel()
        codeLabel.text = " "
        codeLabel.font = UIFont(name: "Geomanist", size: 10.0)
        codeLabel.textColor = textColor ?? UIColor.white
        codeLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        stackView = UIStackView(arrangedSubviews: [amountLabel, codeLabel])
        stackView.axis = .horizontal
        stackView.alignment = .firstBaseline
        stackView.spacing = 0.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        addStackViewContraints()
        
        setNeedsUpdateConstraints()
    }
    
    private func addStackViewContraints() {
        let views: [String: Any] = [ "stackView" : stackView ]
        
        addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=0)-[stackView]", options: [], metrics: nil, views: views)
        )
        
        addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: [], metrics: nil, views: views)
        )
        
        addConstraint(
            NSLayoutConstraint(item: stackView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        )
    }

}
