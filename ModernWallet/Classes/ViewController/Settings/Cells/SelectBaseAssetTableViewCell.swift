//
//  SelectBaseAssetTableViewCell.swift
//  ModernMoney
//
//  Created by Lyubomir Marinov on 23.01.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SelectBaseAssetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var assetTitleLabel: UILabel!
    
    var displayBaseAssetAsSelected = false
    var disposeBag = DisposeBag()
    
    var isSelectedBaseAsset: Bool {
        get { return accessoryType == .checkmark }
        set { accessoryType = newValue ? .checkmark : .none }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3976672535)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
}
