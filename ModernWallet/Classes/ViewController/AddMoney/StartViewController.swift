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
            return String(Localize("addMoney.newDesign.receiveCrypto").suffix(14))
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
        
        kycNeededViewModel.loadingViewModel.isLoading
            .bind(to: self.rx.loading)
            .disposed(by: disposeBag)
        
        kycNeededViewModel.needToFillData
            .map{UIStoryboard(name: "KYC", bundle: nil).instantiateViewController(withIdentifier: "kycTabNVC")}
            .subscribe(onNext: {[weak self] controller in
                self?.navigationController?.present(controller, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        kycNeededViewModel.ok
            .subscribe(onNext: {[weak self] in
                if let vc = self?.addMoneyViaActionVC {
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        kycNeededViewModel.pending
            .map{UIStoryboard(name: "KYC", bundle: nil).instantiateViewController(withIdentifier: "kycPendingVC")}
            .subscribe(onNext: {[weak self] controller in
                self?.navigationController?.present(controller, animated: true)
            })
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
        guard let vc = pickCurrencyToAdd else {
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
        
        vc.assetPicked.bind { [weak self] (asset) in
            self?.asset.value = ApiResult<LWAssetModel>.success(withData: asset)
            }.disposed(by: disposeBag)
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
    
    private var addMoneyViaActionVC: UIViewController? {
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
