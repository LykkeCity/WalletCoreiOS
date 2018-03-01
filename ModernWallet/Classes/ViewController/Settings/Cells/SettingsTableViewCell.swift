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
    
    @IBOutlet weak var separator: SeparatorView!
    
    private var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let backroundView = UIView()
        backroundView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1967840325)
        selectedBackgroundView = backroundView
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        updateBackground(animated: animated)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        updateBackground(animated: animated)
    }
    
    private func updateBackground(animated: Bool) {
        let selectionVisible = isSelected || isHighlighted
        let alphaSettingClosure: () -> () = {
            self.selectedBackgroundView?.alpha = selectionVisible ? 1.0 : 0.0
        }
        let completionClosure: (Bool) -> () = { (success) in
            if !selectionVisible {
                self.selectedBackgroundView?.removeFromSuperview()
            }
        }
        if let selectedBackgroundView = selectedBackgroundView, selectionVisible, selectedBackgroundView.superview == nil {
            contentView.insertSubview(selectedBackgroundView, at: 0)
            selectedBackgroundView.alpha = 0.0
            var backgroundFrame = contentView.bounds
            backgroundFrame.origin.y = 2.0
            backgroundFrame.size.height -= 2.0
            selectedBackgroundView.frame = backgroundFrame
        }
        if animated {
            UIView.animate(withDuration: 0.3, animations: alphaSettingClosure, completion: completionClosure)
        }
        else {
            alphaSettingClosure()
            completionClosure(true)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
}
