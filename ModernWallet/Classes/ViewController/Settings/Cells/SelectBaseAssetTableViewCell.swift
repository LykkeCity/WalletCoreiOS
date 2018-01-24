//
//  SelectBaseAssetTableViewCell.swift
//  ModernMoney
//
//  Created by Lyubomir Marinov on 23.01.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import UIKit

class SelectBaseAssetTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var isSelectedBaseAsset: Bool {
        get { return accessoryType == .checkmark }
        set { accessoryType = newValue ? .checkmark : .none }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3976672535)
    }
    
}
