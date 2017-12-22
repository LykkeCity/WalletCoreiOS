//
//  AddMoneyCryptoCurrencyTableViewCell.swift
//  ModernMoney
//
//  Created by Ivan Stefanovic on 12/20/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Alamofire
import AlamofireImage
import WalletCore

class AddMoneyCryptoCurrencyTableViewCell: UITableViewCell {

  
    @IBOutlet weak var cryptoNameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var cryptoAddressLabel: UILabel!
    
    var disposeBag = DisposeBag()
    
    
    @discardableResult
    func bind(toCurrency currency: AddMoneyCryptoCurrencyCellViewModel) -> Self {
        self.disposeBag = DisposeBag()
        
        currency.name
            .drive(cryptoNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        currency.address
            .drive(cryptoAddressLabel.rx.text)
            .disposed(by: disposeBag)
        
        currency.imgUrl
            .drive(iconImageView.rx.afImage)
            .addDisposableTo(disposeBag)
        
        return self
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        selectedBackgroundView = UIImageView(image: #imageLiteral(resourceName: "highlightBackground"))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
