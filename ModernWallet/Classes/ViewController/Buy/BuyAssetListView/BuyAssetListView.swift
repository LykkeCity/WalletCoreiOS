//
//  BuyAssetListView.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 10/9/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

@IBDesignable
class BuyAssetListView: UIView {

    @IBOutlet weak var tapToSelectAsset: UITapGestureRecognizer!
    @IBOutlet weak var baseAssetCode: UILabel!
    @IBOutlet weak var amontInBase: UILabel!
    @IBOutlet weak var assetCode: UILabel!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var assetName: UILabel!
    @IBOutlet weak var assetIcon: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet var view: UIView!
    
    let itemPicker = (picker: UIPickerView(), field: UITextField())
    
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
        view = loadViewFromNib("BuyAssetListView")
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func setupUX(withButtonTitle buttonTitle: String, disposedBy disposeBag: DisposeBag) {
        itemPicker.field.inputView = itemPicker.picker
        view.addSubview(itemPicker.field)
        
        addButton(forField: itemPicker.field, withTitle: Localize("buy.newDesign.done"))
            .subscribe(onNext: {field in
                field.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        addButton(forField: amount, withTitle: buttonTitle)
            .subscribe(onNext: {field in
                _ = field.delegate?.textFieldShouldReturn?(field)
            })
            .disposed(by: disposeBag)
        
        tapToSelectAsset.rx.event.asObservable()
            .subscribe(onNext: {[weak self] _ in
                self?.itemPicker.field.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
    }
}

extension BuyAssetListView: TextFieldButton{}
