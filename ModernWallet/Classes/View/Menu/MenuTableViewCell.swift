//
//  MenuTableViewCell.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 6/8/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var menuNameLabel: UILabel!
    @IBOutlet weak var menuImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let customSelectionView = UIView()
        customSelectionView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.113869863)
        selectedBackgroundView = customSelectionView
    }
    
}
