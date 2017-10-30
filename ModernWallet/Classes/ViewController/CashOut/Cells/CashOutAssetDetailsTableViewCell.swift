//
//  CashOutAssetDetailsTableViewCell.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 29.10.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import WalletCore

class CashOutAssetDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet private(set) var assetNameLabel: UILabel!
    @IBOutlet private(set) var assetAmountView: AssetAmountView!
    @IBOutlet private(set) var exchangeRateAmountView: AssetAmountView!
    
    private var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        assetAmountView.amountFont = UIFont(name: "Geomanist-Light", size: 16.0)
        assetAmountView.codeFont = UIFont(name: "Geomanist-Light", size: 10.0)
        exchangeRateAmountView.amountFont = UIFont(name: "Geomanist-Light", size: 12.0)
        exchangeRateAmountView.codeFont = UIFont(name: "Geomanist-Light", size: 8.0)
    }
    
    func bind(to viewModel: CashOutViewModel) {
        disposeBag = DisposeBag()
        
        assetAmountView.bind(to: viewModel.amountObservable)
            .disposed(by: disposeBag)
        
        exchangeRateAmountView.bind(to: viewModel.exchangeCourceObservable)
            .disposed(by: disposeBag)
    }

}
