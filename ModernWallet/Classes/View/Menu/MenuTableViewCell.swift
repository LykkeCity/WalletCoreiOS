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
        customSelectionView.backgroundColor = Colors.darkBlue
        selectedBackgroundView = customSelectionView
    }
    
}
