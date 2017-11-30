//
//  ReloadTrigger.swift
//  ModernMoney
//
//  Created by Nacho Nachev on 30.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

class ReloadTrigger {
    
    static let instance = ReloadTrigger()
    
    private let trigger: PublishSubject<Void>
    
    func trigger(interval: RxTimeInterval) -> Observable<Void> {
        return Observable.merge([trigger.asObservable(), Observable.interval(interval)])
    }
    
    var triggerWithNow: Observable<Void> {
        return Observable.merge([trigger.asObservable(), Observable.just(Void())])
    }
    
    func trigger(observable: Observable<Void>) -> Observable<Void> {
        return Observable.merge([trigger.asObservable(), observable])
    }
    
    func reload() {
        trigger.onNext(Void())
    }
    
    // MARK: - Private
    
    private init() {
        trigger = PublishSubject()
    }
    
}
