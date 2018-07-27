//
//  AssetDisclaimerViewController.swift
//  ModernMoney
//
//  Created by Georgi Stanev on 10.05.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import WalletCore
import WebKit

class AssetDisclaimerViewController: UIViewController, WKNavigationDelegate {

    
    @IBOutlet weak var acceptedButton: UIButton!
    @IBOutlet weak var `continue`: UIButton!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    var disclaimerWebView: WKWebView!
    
    // move this variable to a dedicated view model
    let accepted = Variable(false)
    
    fileprivate let currentDisclaimer = Variable<LWModelAssetDisclaimer?>(nil)
    
    private let disposeBag = DisposeBag()
    
    private lazy var viewModel: AssetDisclaimerViewModel = {
        let currentDisclaimer = self.currentDisclaimer
        
        return AssetDisclaimerViewModel(
            accept: self.continue.rx.tap.asDriver().map{ currentDisclaimer.value?.id }.filterNil(),
            decline: self.cancel.rx.tap.asDriver().map{ currentDisclaimer.value?.id }.filterNil(),
            acceptEnabled: self.accepted.asDriver()
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)

        /// UI
        cancel.rx.tap.asObservable()
            .bind { [weak self] in self?.dismiss(animated: true, completion: nil) }
            .disposed(by: disposeBag)

        accepted.asDriver()
            .map{ $0 ? #imageLiteral(resourceName: "CheckboxChecked") : #imageLiteral(resourceName: "CheckboxUnchecked") }
            .drive(acceptedButton.rx.image(for: .normal))
            .disposed(by: disposeBag)
        
        acceptedButton.rx.tap.asDriver()
            .map{ [accepted] in !accepted.value }
            .drive(accepted)
            .disposed(by: disposeBag)
        
        addWebView()
        
        // Do any additional setup after loading the view.
    }
    
    func addWebView() {
        let webConfiguration = WKWebViewConfiguration()
        let customFrame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.containerView.bounds.size.width, height: self.containerView.bounds.size.height))
        disclaimerWebView = WKWebView(frame: customFrame, configuration: webConfiguration)
        disclaimerWebView.translatesAutoresizingMaskIntoConstraints = false
        disclaimerWebView.isOpaque = false
        
        containerView.addSubview(disclaimerWebView)
        
        disclaimerWebView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        disclaimerWebView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        disclaimerWebView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        disclaimerWebView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        disclaimerWebView.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        disclaimerWebView.navigationDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated  {
            if let url = navigationAction.request.url,
                UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    func addCSSToHtml(html: String) -> String {
        let newHtml = """
        <style>
        body {
        font-size: 4.5vw;
        color: white;
        }
        a {
        color: #E4E4E4;
        }
        </style>
        """
            + html
        
        return newHtml
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

fileprivate extension AssetDisclaimerViewModel {
    func bind(toViewController vc: AssetDisclaimerViewController) -> [Disposable] {
        return [
            dismissViewController.drive(onNext: { [weak vc] in vc?.dismiss(animated: true, completion: nil) }),
            loadingViewModel.isLoading.bind(to: vc.rx.loading),
            disclaimer.drive(vc.currentDisclaimer),
            vc.currentDisclaimer.asDriver().filterNil().drive(onNext: { [weak vc] disclaimer in
                let page = vc?.addCSSToHtml(html: disclaimer.text)
                if let openHtml = page {
                vc?.disclaimerWebView.loadHTMLString(openHtml, baseURL: URL(string: "https://"))
                }
            }),
            vc.accepted.asDriver().drive(vc.continue.rx.isEnabled)
        ]
    }
}
