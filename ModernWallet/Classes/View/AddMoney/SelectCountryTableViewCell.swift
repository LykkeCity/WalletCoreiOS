//
//  SelectCountryTableViewCell.swift
//  ModernMoney
//
//  Created by Nacho Nachev  on 12.01.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import UIKit

class SelectCountryTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    
    var name: String? {
        get { return nameLabel.text }
        set { nameLabel.text = newValue }
    }
    
    var isSelectedCountry: Bool {
        get { return accessoryType == .checkmark }
        set { accessoryType = newValue ? .checkmark : .none }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3976672535)
    }

}
