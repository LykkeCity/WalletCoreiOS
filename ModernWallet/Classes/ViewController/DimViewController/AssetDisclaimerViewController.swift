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
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var disclaimerWebView: WebView!
    
    fileprivate let accepted = Variable(false)
    
    fileprivate let currentDisclaimer = Variable<LWModelAssetDisclaimer?>(nil)
    
    private let disposeBag = DisposeBag()
    
    private lazy var viewModel: AssetDisclaimerViewModel = {
        let currentDisclaimer = self.currentDisclaimer
        
        return AssetDisclaimerViewModel(
            accept: self.continueButton.rx.tap.asDriver().map{ currentDisclaimer.value?.id }.filterNil(),
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
        
        disclaimerWebView.navigationDelegate = self
        
        // Do any additional setup after loading the view.
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
            vc.currentDisclaimer.asDriver().filterNil().waitFor(loadingViewModel.isLoading).drive(onNext: { [weak vc] disclaimer in
                var openHtml = String()
                openHtml.addDiscaimerStyle(html: disclaimer.text)
                vc?.disclaimerWebView.loadHTMLString(openHtml, baseURL: URL(string: "https://"))
            }),
            vc.accepted.asDriver().drive(vc.continueButton.rx.isEnabled)
        ]
    }
}
