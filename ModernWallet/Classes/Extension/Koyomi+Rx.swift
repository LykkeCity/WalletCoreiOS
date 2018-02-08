//
//  Koyomi+Rx.swift
//  ModernMoney
//
//  Created by Lyubomir Marinov on 2.02.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Koyomi

// MARK: - Binding observer to update the current Date
extension Reactive where Base: Koyomi {
    /// Select date on the calendar
    var selectDate: UIBindingObserver<Base, Date?> {
        return UIBindingObserver(UIElement: self.base) { calendar, value in
            guard let value = value else {
                self.base.unselectAll()
                return
            }
            self.base.select(date: value)
        }
    }
    
    var prevMonth: UIBindingObserver<Base, Void> {
        return UIBindingObserver(UIElement: self.base, binding: { (calendar, _) in
            self.base.display(in: .previous)
        })
    }
    
    var nextMonth: UIBindingObserver<Base, Void> {
        return UIBindingObserver(UIElement: self.base, binding: { (calendar, _) in
            self.base.display(in: .next)
        })
    }
}

class KoyomiDelegateProxy: DelegateProxy, DelegateProxyType, KoyomiDelegate {
    static func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        guard let koyomiObject: Koyomi = object as? Koyomi else { return nil }
        
        return koyomiObject.calendarDelegate
    }
    
    static func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        guard let koyomiObject: Koyomi = object as? Koyomi else { return }
        
        koyomiObject.calendarDelegate = delegate as? KoyomiDelegate
    }
}

extension Koyomi {
    private var rx_delegate: DelegateProxy {
        return KoyomiDelegateProxy.proxyForObject(self)
    }
    
    public var rx_selectedDate: Observable<Date> {
        let selector = #selector(KoyomiDelegate.koyomi(_:didSelect:forItemAt:))
        return rx_delegate.methodInvoked(selector)
            .map { params in
                return params[1] as? Date
        }.filterNil()
        .shareReplay(1)
    }
    
    public var rx_displayedMonth: Observable<String> {
        let selector = #selector(KoyomiDelegate.koyomi(_:currentDateString:))
        return rx_delegate.methodInvoked(selector)
            .map { params in
                return params[1] as? String
        }.filterNil()
        .shareReplay(1)
    }
}

