//
//  DimPresentationController.swift
//  SOCOTAB
//
//  Created by Georgi Ivanov on 22.02.18.
//  Copyright © 2018 Primeholding AD. All rights reserved.
//

import UIKit

class DimPresentationController: UIPresentationController {
    
    private var dimmingView: UIView
    let duration: Float
    let style = UIBlurEffectStyle.light
    
    
    init(presentedVc: UIViewController, presenting
        presentingVc: UIViewController?,
         duration: Float,
         dimColor: UIColor) {
        self.duration = duration
        let dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = dimColor
        self.dimmingView = dimmingView
        
        super.init(presentedViewController: presentedVc, presenting: presentingVc)
    }
    
    override func presentationTransitionWillBegin() {
        containerView?.insertSubview(dimmingView, at: 0)
        presentedView?.backgroundColor = UIColor.clear
        dimmingView.pinToSuperview()
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {
        return parentSize
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let bounds = containerView?.bounds else {
            return .zero
        }
        return bounds
    }
}
