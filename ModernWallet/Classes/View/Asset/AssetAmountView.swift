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
        set { amountLabel?.font = newValue }
    }
    
    @IBInspectable var codeFont: UIFont? {
        get { return codeLabel?.font }
        set { codeLabel?.font = newValue }
    }
    
    @IBInspectable var textColor: UIColor? {
        didSet {
            amountLabel.textColor = textColor
            codeLabel.textColor = textColor
        }
    }
    
    @IBInspectable var spacing: CGFloat {
        get { return stackView.spacing }
        set { stackView.spacing = newValue }
    }
    
    var amount: String? {
        get { return amountLabel?.text }
        set { amountLabel?.text = newValue }
    }
    
    var code: String? {
        get { return codeLabel?.text }
        set { codeLabel?.text = newValue }
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
        var amountLabelIsEmpty = false
        if amountLabel.text?.count ?? 0 == 0 {
            amountLabel.text = "I"
            amountLabelIsEmpty = true
        }
        let amountSize = amountLabel.intrinsicContentSize
        if amountLabelIsEmpty {
            amountLabel.text = ""
        }
        var codeLabelIsEmpty = false
        if codeLabel.text?.count ?? 0 == 0 {
            codeLabel.text = "I"
            codeLabelIsEmpty = true
        }
        let codeSize = codeLabel.intrinsicContentSize
        if codeLabelIsEmpty {
            codeLabel.text = ""
        }
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
