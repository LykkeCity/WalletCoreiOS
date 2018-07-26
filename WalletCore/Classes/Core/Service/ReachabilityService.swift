//
//  ReachabilityService.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 16.02.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Reachability

public class ReachabilityService {
    /// Singleton instance
    public static let instance = ReachabilityService()

    /// The Reachability object
    private var reachability: Reachability

    private let _reachabilityStatus = BehaviorSubject<Bool>(value: false)

    public var reachabilityStatus: Observable<Bool> {
        return _reachabilityStatus.asObservable()
            .distinctUntilChanged()
    }

    init() {

        reachability = Reachability()!
        reachability.allowsCellularConnection = true

        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged(_:)), name: .reachabilityChanged, object: reachability)

        do {
            try reachability.startNotifier()
        } catch {}
    }

    @objc func reachabilityChanged(_ notification: Notification) {

        let reachability = notification.object as! Reachability

        switch reachability.connection {
        case .wifi, .cellular:
            self._reachabilityStatus.onNext(true)
        case .none:
            self._reachabilityStatus.onNext(false)
        }
    }

    deinit {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
}
