//
//  UIImageView+Rx.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 8/1/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AlamofireImage
import Alamofire
import WalletCore
import SwiftSpinner

extension Reactive where Base: UIImageView {
    /// Bindable sink for `enabled` property.
    var isHighlighted: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { imageView, value in
            imageView.isHighlighted = value
        }
    }
    
    /// - parameter transitionType: Optional transition type while setting the image (kCATransitionFade, kCATransitionMoveIn, ...)
    var afImage: UIBindingObserver<Base, URL?> {
        return UIBindingObserver(UIElement: base) { imageView, url in
            guard let url = url else {
                imageView.image = nil
                return
            }
            
            imageView.af_setImage(withURL: url, useToken: false)
        }
    }
    
    /// - parameter transitionType: Optional transition type while setting the image (kCATransitionFade, kCATransitionMoveIn, ...)
    var afImageAuthorized: UIBindingObserver<Base, URL> {
        return UIBindingObserver(UIElement: base) { imageView, url in
            imageView.af_setImage(withURL: url, useToken: true)
        }
    }
}

extension UIImageView {
    func af_setImage(withURL url: URL, useToken: Bool, loaderHolder: UIViewController? = nil) {
        
        var urlRequest = URLRequest(url: url)
        
        if useToken, let token = LWKeychainManager.instance()?.token {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if loaderHolder != nil {SwiftSpinner.show("Loading...", animated: true)}
        
        Alamofire.request(urlRequest).responseImage { [weak self] response in
            if loaderHolder != nil {SwiftSpinner.hide()}
            if let image = response.result.value {
                self?.image = image
            }
        }
    }
}
