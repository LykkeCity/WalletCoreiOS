//
//  KYCPhotoFailedTableViewCell.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 10/2/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import RxSwift
import RxCocoa

class KYCPhotoFailedTableViewCell: UITableViewCell {

    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
