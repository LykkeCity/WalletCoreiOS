//
//  DimPresentationAnimator.swift
//  SOCOTAB
//
//  Created by Georgi Ivanov on 22.02.18.
//  Copyright © 2018 Primeholding AD. All rights reserved.
//

import UIKit

class DimPresentationAnimator: NSObject {
    let isPresenting: Bool
    var duration: TimeInterval = 0.2
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
        super.init()
    }
}

extension DimPresentationAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let key = isPresenting ? UITransitionContextViewControllerKey.to : UITransitionContextViewControllerKey.from
        let controller = transitionContext.viewController(forKey: key)!
        
        slideTransition(transitionContext, controller: controller)
    }
    
    func slideTransition(_ context: UIViewControllerContextTransitioning, controller: UIViewController) {
        if isPresenting {
            context.containerView.addSubview(controller.view)
        }
        
        var startFrame = CGRect()
        var finishFrame = CGRect()
        
        if isPresenting {
            startFrame = CGRect(y: context.containerView.frame.size.height,
                                rect: controller.view.frame)
            finishFrame = context.containerView.frame
        } else {
            startFrame = controller.view.frame
            finishFrame = CGRect(y: context.containerView.frame.size.height,
                                 rect: controller.view.frame)
        }
        
        controller.view.frame = startFrame
        
        UIView.animate(withDuration: duration, animations: {
            controller.view.frame = finishFrame
        }) { (finished) in
            context.completeTransition(finished)
        }
        
        let dimView = context.containerView.subviews[0]
        fadeView(dimView, maxAlpha: 1, context: context)
    }
    
    func fadeView(_ view: UIView, maxAlpha: CGFloat, context: UIViewControllerContextTransitioning) {
        let newAlpha: CGFloat = isPresenting ? maxAlpha : 0
        
        if isPresenting {
            view.alpha = 0
        }
        
        let duration = transitionDuration(using: context)
        UIView.animate(withDuration: duration) {
            view.alpha = newAlpha
        }
    }
}

extension CGRect {
    init(y: CGFloat, rect: CGRect) {
        self.init(x: rect.origin.x, y: y, width: rect.size.width, height: rect.size.height)
    }
}
