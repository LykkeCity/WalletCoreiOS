//
//  StartViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 6/28/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import RxSwift

class StartViewController: UIViewController {
    
    @IBOutlet weak var bankAccountLabel: UILabel!
    @IBOutlet weak var creditCardLabel: UILabel!
    @IBOutlet weak var receiveCryptoLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    
    private let asset = Variable<ApiResult<LWAssetModel>?>(nil)
    private lazy var kycNeededViewModel: KycNeededViewModel = {
        return KycNeededViewModel(forAsset: self.asset.asObservable().filterNil())
    }()
    
    private enum ActionType {
        case bankAccount
        case creditCard
        case cryptoCurrency
    }
    
    private var action: ActionType?
    
    public var selectedPaymentMethod: String {
        guard let action = action else { return "" }
        
        switch action {
        case .bankAccount:
            return Localize("addMoney.newDesign.bankAccount")
        case .creditCard:
            return Localize("addMoney.newDesign.creditCard")
        case .cryptoCurrency:
            return Localize("addMoney.newDesign.cryptoCurrency")
        }
    }
    
    func presentPendingViewController() {
        let pendingViewController = UIStoryboard(name: "KYC", bundle: nil).instantiateViewController(withIdentifier: "kycPendingVC")
        navigationController?.present(pendingViewController, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default
            .addObserver(self, selector: #selector(StartViewController.presentPendingViewController), name: .kycDocumentsUploadedOrApproved, object: nil)
        
        view.backgroundColor = UIColor.clear
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        bankAccountLabel.text = Localize("addMoney.newDesign.bankAccount")
        creditCardLabel.text = Localize("addMoney.newDesign.creditCard")
        receiveCryptoLabel.text = Localize("addMoney.newDesign.receiveCrypto")
        
        kycNeededViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
    }
    
    @IBAction func bankAccountAction(_ sender: UIButton) {
        action = .bankAccount
        askForAssetType()
    }
    
    @IBAction func creditCardAction(_ sender: UIButton) {
        action = .creditCard
        askForAssetType()
    }
    
    @IBAction func cryptoCurrencyAction(_ sender: UIButton) {
        action = .cryptoCurrency
    }

    private func askForAssetType() {
        guard let vc = pickCurrencyToAdd else { return }
        navigationController?.pushViewController(vc, animated: true)
        
        // use asset picker disposeBag for this binding so that when the view controller gets destroyed
        // the binding will be disposed
        vc.assetPicked
            .mapToApiResult()
            .bind(to: asset)
            .disposed(by: vc.disposeBag)
    }
    
    private var pickCurrencyToAdd: AssetPickerTableViewController? {
        guard let action = action else {
            return nil
        }
        
        let vc = AssetPickerTableViewController.instantiateViewController()
        
        switch action {
        case .bankAccount:
            vc.showOnlyAssetsWithSwiftTransfer()
            break
        case .creditCard:
            vc.showOnlyVisaDepositableAssets()
            break
        case .cryptoCurrency:
            break
        }
        
        return vc
    }
    
    fileprivate var addMoneyViaActionVC: UIViewController? {
        guard let action = action else {
            return nil
        }
        
        var vc: UIViewController! = nil
        switch action {
        case .bankAccount:
            vc = storyboard?.instantiateViewController(withIdentifier: "bankInfo")
        case .creditCard:
            vc = storyboard?.instantiateViewController(withIdentifier: "addMoneyCCstep1VC")
        case .cryptoCurrency:
            vc = nil
        }
        
        if let vc = vc as? AddMoneyTransfer,
            let asset = self.asset.value?.getSuccess() {
            vc.assetToAdd = asset
        } else {
            let msg = "Could not pass transfer asset(\(String(describing: self.asset.value)) to vc: \(vc)"
            assertionFailure(msg)
        }
        
        return vc
    }
}

fileprivate extension ObservableType where Self.E == LWAssetModel {
    func mapToApiResult() -> Observable<ApiResult<LWAssetModel>> {
        return flatMap{ asset in
            Observable
                .just(.success(withData: asset))
                .startWith(.loading)
        }
    }
}

fileprivate extension KycNeededViewModel {
    func bind(toViewController vc: StartViewController) -> [Disposable] {
        return [
            loadingViewModel.isLoading.bind(to: vc.rx.loading),
            needToFillData
                .map{ UIStoryboard(name: "KYC", bundle: nil).instantiateViewController(withIdentifier: "kycTabNVC") }
                .subscribe(onNext: {[weak vc] controller in
                    vc?.navigationController?.present(controller, animated: true, completion: nil)
                }),
            
            ok.subscribe(onNext: {[weak vc] in
                if let vc = vc?.addMoneyViaActionVC {
                    vc.navigationController?.pushViewController(vc, animated: true)
                }
            }),
            
            pending
                .map{UIStoryboard(name: "KYC", bundle: nil).instantiateViewController(withIdentifier: "kycPendingVC")}
                .subscribe(onNext: {[weak vc] controller in
                    vc?.navigationController?.present(controller, animated: true)
                }),
        ]
    }
}
