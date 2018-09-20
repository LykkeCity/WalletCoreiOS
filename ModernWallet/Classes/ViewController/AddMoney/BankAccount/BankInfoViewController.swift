//
//  BankInfoViewControllerViewController.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 16.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class BankInfoViewController: AddMoneyBaseViewController {

    @IBOutlet weak var emailButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    private lazy var currencyDepositViewModel: CurrencyDepositViewModel = {
        return CurrencyDepositViewModel(trigger: self.emailButton.rx.tap.asObservable())
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if TEST
            emailButton.isEnabled = false
        #endif
        
        emailButton.setTitle(Localize("addMoney.newDesign.bankaccount.emailMe"), for: UIControlState.normal)
        
        currencyDepositViewModel.assetId.value = assetToAdd.identity
        // !!!: For VM to work properly it needs balance value, but currently
        // we have no UI for the amount so we set it to 1
        // In the sent email the user sees 1 as transfer amount
        currencyDepositViewModel.balanceChange.value = 1

        currencyDepositViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSwiftCredentials",
            let transferVC = segue.destination as? AddMoneyTransfer,
            let asset = self.assetModel.value {
            transferVC.assetToAdd = asset
        }
    }
}

fileprivate extension CurrencyDepositViewModel {
    func bind(toViewController vc: BankInfoViewController) -> [Disposable] {
        return [
            loadingViewModel.isLoading.bind(to: vc.rx.loading),
            result.drive(onNext: { [weak vc] _ in
                vc?.performSegue(withIdentifier: "showWireBankEmailSent", sender: nil)
            }),
            errors.bind(to: vc.rx.error)
        ]
    }
}
