//
//  Array+Rx.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 24.10.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Array where Element == Disposable {
    
    func disposed(by disposeBag: DisposeBag) {
        self.forEach { $0.disposed(by: disposeBag) }
    }
    
}
