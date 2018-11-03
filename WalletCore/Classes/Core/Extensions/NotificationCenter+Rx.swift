//
//  NotificationCenter+Rx.swift
//  WalletCore
//
//  Created by Georgi Stanev on 4.11.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType {
    /// Post a notification in the notification center on nextEvent (when success)
    ///
    /// - Parameters:
    ///   - notification: A notification name that will be posted
    ///   - center: Notification center where the notification will be posted
    /// - Returns: Observable
    func postWhenSuccess<T>(
        notification: Notification.Name,
        inCenter center: NotificationCenter = NotificationCenter.default
    ) -> Observable<Self.E> where Self.E == ApiResult<T> {
        return `do`(onNext: {
            if let object = $0.getSuccess() {
                center.post(name: notification, object: object)
            }
        })
    }
}
