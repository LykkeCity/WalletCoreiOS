//
//  AssetCollectionViewCell.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 11.10.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Alamofire
import AlamofireImage
import WalletCore

class AssetCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var cryptoNameLabel: UILabel!
    @IBOutlet weak private var baseAmountView: AssetAmountView!
    @IBOutlet weak private var cryptoAmountView: AssetAmountView!
    
    private var disposeBag = DisposeBag()
    
    override var isSelected: Bool {
        didSet {
            let alpha: CGFloat = isSelected ? 1.0 : 0.6
            iconImageView.alpha = alpha
            cryptoNameLabel.alpha = alpha
            cryptoAmountView.alpha = alpha
            baseAmountView.alpha = alpha
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)

        isSelected = false
        
        baseAmountView.amountFont = UIFont(name: "Geomanist-Light", size: 15.0)
        cryptoAmountView.amountFont = UIFont(name: "Geomanist-Light", size: 12.0)
        cryptoAmountView.codeFont = UIFont(name: "Geomanist", size: 8.0)
    }

    @discardableResult
    func bind(toAsset asset: AssetCollectionCellViewModel) -> Self {
        self.disposeBag = DisposeBag()
        
        asset.name
            .drive(cryptoNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        asset.driveAmountInBase(to: baseAmountView)
            .disposed(by: disposeBag)
        
        asset.driveAmount(to: cryptoAmountView)
            .disposed(by: disposeBag)
        
        asset.imgURL
            .filterNil()
            .drive(iconImageView.rx.afImage)
            .disposed(by: disposeBag)
        
        return self
    }

}
