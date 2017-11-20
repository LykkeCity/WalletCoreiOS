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

public extension UIScrollView {
    
    /// Subscribe for following keyboard events
    /// - willShowVisibleHeight - Autoscroll to the focused field so that it's not hidden by the keyboard
    /// - isHidden - Set contentInset.bottom = 0 once keyboard gets hidden
    /// - Parameter disposeBag: DisposedBag that disposes the two subscriptions
    func subscribeKeyBoard(withDisposeBag disposeBag: DisposeBag) {
        RxKeyboard.instance.frame
            .drive(onNext: { [weak self] keyboardFrame in
                guard
                    let `self` = self,
                    let rootView = self.window?.rootViewController?.view
                    else {
                        return
                }
                let scrollViewFrame = rootView.convert(self.bounds, from: self)
                let intersectionHeight = scrollViewFrame.intersection(keyboardFrame).height
                self.contentInset.bottom = intersectionHeight
            })
            .disposed(by: disposeBag)
    }
}


