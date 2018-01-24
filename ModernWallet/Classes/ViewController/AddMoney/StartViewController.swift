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
    }
    
    private var action: ActionType?
    
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
            .map{ [weak self] in self?.instantiatedViewController }
            .filterNil()
            .subscribe(onNext: {[weak self] controller in
                self?.navigationController?.pushViewController(controller, animated: true)
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
        requestBaseAsset()
    }
    
    @IBAction func creditCardAction(_ sender: UIButton) {
        action = .creditCard
        requestBaseAsset()
    }
    
    private var instantiatedViewController: UIViewController? {
        guard let action = action else { return nil }
        
        switch action {
            case .bankAccount:
                return storyboard?.instantiateViewController(withIdentifier: "bankInfo")
            case .creditCard:
                return storyboard?.instantiateViewController(withIdentifier: "addMoneyCCstep1VC")
        }
    }
    
    private func requestBaseAsset() {
        LWRxAuthManager.instance.baseAsset.request()
            .bind(to: asset)
            .disposed(by: disposeBag)
    }
    
}
