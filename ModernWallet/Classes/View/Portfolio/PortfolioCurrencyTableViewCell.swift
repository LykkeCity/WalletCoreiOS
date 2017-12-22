//
//  PortfolioCurrencyTableViewCell.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 6/5/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Alamofire
import AlamofireImage
import WalletCore

class PortfolioCurrencyTableViewCell: UITableViewCell {

    @IBOutlet weak var iconHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cryptoNameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var cryptoValueLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    var disposeBag = DisposeBag()
    
    @discardableResult
    func bind(toAsset asset: AssetCellViewModel) -> Self {
        self.disposeBag = DisposeBag()
        
        asset.name
            .drive(cryptoNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        asset.cryptoValue
            .drive(cryptoValueLabel.rx.text)
            .disposed(by: disposeBag)
        
        asset.realValue
            .drive(valueLabel.rx.text)
            .disposed(by: disposeBag)
        
        asset.percent
            .drive(percentLabel.rx.text)
            .disposed(by: disposeBag)
        
        asset.imgURL
            .drive(iconImageView.rx.afImage)
            .disposed(by: disposeBag)
        
        return self
    }
    
    @discardableResult
    func bind(toCurrency currency: CryptoCurrencyCellViewModel) -> Self {
        self.disposeBag = DisposeBag()
        
        currency.name
            .drive(cryptoNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        currency.capitalization
            .drive(percentLabel.rx.text)
            .disposed(by: disposeBag)
        
        currency.variance
            .drive(cryptoValueLabel.rx.text)
            .disposed(by: disposeBag)
        
        currency.percentVariance
            .drive(valueLabel.rx.text)
            .disposed(by: disposeBag)
        
        currency.imgUrl
            .drive(iconImageView.rx.afImage)
            .addDisposableTo(disposeBag)
        
        return self
    }
    @discardableResult
    func bindCrypto(toCurrency currency: CryptoCurrencyCellViewModel) -> Self {
        self.disposeBag = DisposeBag()
        
        currency.name
            .drive(cryptoNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        currency.capitalization
            .drive(percentLabel.rx.text)
            .disposed(by: disposeBag)
        
        
        currency.imgUrl
            .drive(iconImageView.rx.afImage)
            .addDisposableTo(disposeBag)
        
        return self
    }
    
    @discardableResult
    func bind(toTransaction transaction: TransactionViewModel) -> Self {
        self.disposeBag = DisposeBag()
        
        transaction.title
            .drive(cryptoNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        transaction.amaunt
            .drive(cryptoValueLabel.rx.text)
            .disposed(by: disposeBag)
        
        transaction.amauntInBase
            .drive(valueLabel.rx.text)
            .disposed(by: disposeBag)
        
        transaction.date
            .drive(percentLabel.rx.text)
            .disposed(by: disposeBag)
        
        transaction.icon
            .drive(iconImageView.rx.image)
            .disposed(by: disposeBag)
        
        
//        let height = CGFloat(0.0)
//        
//        if iconHeightConstraint.constant != height {
//            iconHeightConstraint.constant = height
//        }
        
        return self
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectedBackgroundView = UIImageView(image: #imageLiteral(resourceName: "highlightBackground"))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
