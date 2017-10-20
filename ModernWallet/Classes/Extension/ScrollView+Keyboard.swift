//
//  ScrollView+Keyboard.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 9/8/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import UIKit
import RxKeyboard
import RxSwift

extension UIScrollView {
    
    /// Subscribe for following keyboard events
    /// - willShowVisibleHeight - Autoscroll to the focused field so that it's not hidden by the keyboard
    /// - isHidden - Set contentInset.bottom = 0 once keyboard gets hidden
    /// - Parameter disposeBag: DisposedBag that disposes the two subscriptions
    func subscribeKeyBoard(withDisposeBag disposeBag: DisposeBag) {
        RxKeyboard.instance.willShowVisibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                self?.contentInset.bottom = keyboardVisibleHeight
            })
            .disposed(by: disposeBag)
        
        RxKeyboard.instance.isHidden
            .filter{$0}
            .drive(onNext: {[weak self] _ in
                self?.contentInset.bottom = 0
            })
            .disposed(by: disposeBag)
    }
}

