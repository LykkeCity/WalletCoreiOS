//
//  DimPresentationManager.swift
//  SOCOTAB
//
//  Created by Georgi Ivanov on 22.02.18.
//  Copyright © 2018 Primeholding AD. All rights reserved.
//

import UIKit

class DimPresentationManager: NSObject {
    
    var duration: Float
    var dimColor: UIColor
    
    static let shared = DimPresentationManager(duration: 1.0,
                                               dimColor: UIColor(r: 25, g: 25, b: 25, a: 153))
    
    init(duration: Float, dimColor: UIColor) {
        self.duration = duration
        self.dimColor = dimColor
    }
}

extension DimPresentationManager: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = DimPresentationController(presentedVc: presented,
                                                               presenting: presenting,
                                                               duration: duration,
                                                               dimColor: dimColor)
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DimPresentationAnimator(isPresenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            return DimPresentationAnimator(isPresenting: false)
    }
}
