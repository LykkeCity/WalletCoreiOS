//
//  FinalizePendingRequestsTrigger.swift
//  ModernMoney
//
//  Created by Nacho Nachev on 7.12.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

class FinalizePendingRequestsTrigger {
    
    static let instance = FinalizePendingRequestsTrigger()
    
    private let trigger: PublishSubject<Void>
    
    func trigger(interval: RxTimeInterval) -> Observable<Void> {
        return Observable.merge([trigger.asObservable(), Observable.interval(interval)])
    }
    
    func finalizeNow() {
        trigger.onNext(Void())
    }
    
    // MARK: - Private
    
    private init() {
        trigger = PublishSubject()
    }
    
}

