//
//  SettingsTermsOfUseViewController.swift
//  ModernMoney
//
//  Created by Ivan Stefanovic on 1/25/18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class SettingsTermsOfUseViewController: UIViewController {
    
    @IBOutlet private weak var webView: UIWebView!
    
    private let disposeBag = DisposeBag()
    
    fileprivate lazy var applicationInfoViewModel: ApplicationInfoViewModel = {
        return ApplicationInfoViewModel()
    }()
    
    fileprivate lazy var loadingViewModel: LoadingViewModel = {
        return LoadingViewModel([
            self.applicationInfoViewModel.isLoading,
            self.webView.rx.didFinishLoad.map{ _ in false }.startWith(true)
            ])
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Localize("settings.newDesign.termsOfUse")
       
        loadingViewModel.isLoading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
        applicationInfoViewModel.termsOfUse
            .asObservable()
            .subscribe(onNext: {[weak self] url in
                self?.webView.loadRequest(URLRequest(url:URL(string:url)!))
            })
            .disposed(by: disposeBag)
        
        
    }
    
}


