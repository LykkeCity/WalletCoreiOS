//
//  ReceiveWalletViewController.swift
//  ModernMoney
//
//  Created by Nacho Nachev on 7.12.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit

class ReceiveWalletViewController: UIViewController {
    
    override var modalPresentationStyle: UIModalPresentationStyle {
        get { return .custom }
        set {}
    }
    
    override var transitioningDelegate: UIViewControllerTransitioningDelegate? {
        get { return self }
        set {}
    }
    
    override var preferredContentSize: CGSize {
        get { return CGSize(width: max(Display.width - 60.0, 300.0), height: 440.0) }
        set {}
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - IBActions
    
    @IBAction func closeTapped() {
        dismiss(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ReceiveWalletViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CenteredAnimatedTransitioning(presenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CenteredAnimatedTransitioning(presenting: false)
    }
    
}

class CenteredAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let presenting: Bool
    
    init(presenting: Bool) {
        self.presenting = presenting
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        if presenting {
            guard
                let viewController = transitionContext.viewController(forKey: .to),
                let view = viewController.view
            else { return }
            containerView.addSubview(view)
            let containerBounds = containerView.bounds
            var frame = CGRect(origin: .zero, size: viewController.preferredContentSize)
            frame.origin.y = containerBounds.maxY
            frame.origin.x = (containerBounds.width - frame.width) / 2.0
            view.frame = frame
            containerView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           animations: {
                            view.frame.origin.y = (containerBounds.height - view.frame.height) / 2.0
                            containerView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
            },
                           completion: { _ in
                            transitionContext.completeTransition(true)
            })
        }
        else {
            guard let view = transitionContext.viewController(forKey: .from)?.view else { return }
            containerView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
            let containerBounds = containerView.bounds
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           animations: {
                            view.frame.origin.y = containerBounds.maxY
                            containerView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            },
                           completion: { _ in
                            transitionContext.completeTransition(true)
            })
        }
    }
}
