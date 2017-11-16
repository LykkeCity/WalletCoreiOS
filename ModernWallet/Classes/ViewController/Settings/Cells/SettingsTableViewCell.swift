//
//  SettingsTableViewCell.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 14.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    
    private var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let backroundView = UIView()
        backroundView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1967840325)
        selectedBackgroundView = backroundView
    }
    
    func set(title: String?, icon: Variable<UIImage>, subtitle: Variable<String>? = nil) {
        disposeBag = DisposeBag()
        icon.asDriver()
            .drive(iconView.rx.image)
            .disposed(by: disposeBag)
        titleLabel.text = title
        if let subtitle = subtitle {
            subtitle.asDriver()
                .drive(subtitleLabel.rx.text)
                .disposed(by: disposeBag)
            subtitleLabel.isHidden = false
        }
        else {
            subtitleLabel.isHidden = true
        }
    }
    
}
