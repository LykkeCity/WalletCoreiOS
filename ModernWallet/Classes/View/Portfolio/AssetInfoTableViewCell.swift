//
//  AssetInfoTableViewCell.swift
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

class AssetInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var iconHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var topLeftLabel: UILabel!
    @IBOutlet weak var topRightLabel: UILabel!
    @IBOutlet weak var bottomLeftLabel: UILabel!
    @IBOutlet weak var bottomRightLabel: UILabel!
    
    var disposeBag = DisposeBag()
    
    @discardableResult
    func bind(toAsset asset: AssetCellViewModel) -> Self {
        
        asset.name
            .drive(topLeftLabel.rx.text)
            .disposed(by: disposeBag)
        
        asset.cryptoValue
            .drive(topRightLabel.rx.text)
            .disposed(by: disposeBag)
        
        asset.percent
            .drive(bottomLeftLabel.rx.text)
            .disposed(by: disposeBag)
        
        asset.realValue
            .drive(bottomRightLabel.rx.text)
            .disposed(by: disposeBag)
        
        asset.imgURL
            .drive(iconImageView.rx.afImage)
            .disposed(by: disposeBag)
        
        return self
    }
    
    @discardableResult
    func bind(toCurrency currency: CryptoCurrencyCellViewModel) -> Self {
        
        currency.name
            .drive(topLeftLabel.rx.text)
            .disposed(by: disposeBag)
        
        currency.capitalization
            .drive(bottomLeftLabel.rx.text)
            .disposed(by: disposeBag)
        
        currency.variance
            .drive(topRightLabel.rx.text)
            .disposed(by: disposeBag)
        
        currency.percentVariance
            .drive(bottomRightLabel.rx.text)
            .disposed(by: disposeBag)
        
        currency.imgUrl
            .drive(iconImageView.rx.afImage)
            .addDisposableTo(disposeBag)
        
        return self
    }
    @discardableResult
    func bindCrypto(toCurrency currency: CryptoCurrencyCellViewModel) -> Self {
        
        currency.name
            .drive(topLeftLabel.rx.text)
            .disposed(by: disposeBag)
        
        currency.capitalization
            .drive(bottomLeftLabel.rx.text)
            .disposed(by: disposeBag)
        
        
        currency.imgUrl
            .drive(iconImageView.rx.afImage)
            .addDisposableTo(disposeBag)
        
        return self
    }
    
    @discardableResult
    func bind(toTransaction transaction: TransactionViewModel) -> Self {
    
        transaction.title
            .drive(topLeftLabel.rx.text)
            .disposed(by: disposeBag)
        
        transaction.amount
            .drive(topRightLabel.rx.text)
            .disposed(by: disposeBag)
        
        transaction.amountInBase
            .drive(bottomRightLabel.rx.text)
            .disposed(by: disposeBag)
        
        transaction.date
            .drive(bottomLeftLabel.rx.text)
            .disposed(by: disposeBag)
        
        transaction.icon
            .drive(iconImageView.rx.image)
            .disposed(by: disposeBag)
        
        return self
    }
    
    @discardableResult
    func bind(toMarketCapItem marketCapItem: MarketCapViewModel) -> Self {
        
        marketCapItem.symbol
            .drive(topLeftLabel.rx.text)
            .disposed(by: disposeBag)
        
        marketCapItem.price
            .drive(topRightLabel.rx.text)
            .disposed(by: disposeBag)
        
        marketCapItem.marketCap
            .drive(bottomLeftLabel.rx.text)
            .disposed(by: disposeBag)
        
        marketCapItem.percentChange
            .drive(bottomRightLabel.rx.text)
            .disposed(by: disposeBag)

        iconImageView.isHidden = true
        iconHeightConstraint.constant = 0.0
//        marketCapItem.imgUrl
//            .drive(iconImageView.rx.afImage)
//            .disposed(by: disposeBag)
        
        return self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
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
