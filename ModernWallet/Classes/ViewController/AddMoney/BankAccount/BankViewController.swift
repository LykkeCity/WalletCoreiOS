//
//  BankViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 6/28/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import RxSwift
import RxCocoa
import Toast

/// Define the localization strings in an Enum
private enum BankData: String {
    case bic = "deposit.swift.titles.bic"
    case accountNumber = "deposit.swift.titles.account.number"
    case accountName = "deposit.swift.titles.account.name"
    case bankAddress = "deposit.swift.titles.bank.address"
    case companyAddress = "deposit.swift.titles.company.address"
    case paymentPurpose = "deposit.swift.titles.purpose"
}

class BankViewController: AddMoneyBaseViewController {
    
    @IBOutlet weak var bicLabel: UILabel!
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var purposeOfPaymentLabel: UILabel!
    @IBOutlet weak var bankAddressLabel: UILabel!
    @IBOutlet weak var companyAddressLabel: UILabel!
    
    @IBOutlet weak var bicLbl: UILabel!
    @IBOutlet weak var accountNumberLbl: UILabel!
    @IBOutlet weak var accountNameLbl: UILabel!
    @IBOutlet weak var purposeOfPaymentLbl: UILabel!
    @IBOutlet weak var bankAddressLbl: UILabel!
    @IBOutlet weak var companyAddressLbl: UILabel!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    lazy var swiftCredentialsViewModel: SwiftCredentialsViewModel? = {
        guard let asset = self.assetModel.value else { return nil }
        return SwiftCredentialsViewModel(credentialsForAsset: asset)
    }()
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.clear
        
        applyTranslations()
        
        guard let swiftCredentialsViewModel = swiftCredentialsViewModel else { return }
        
        swiftCredentialsViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
    }
    
    func applyTranslations() {
        bicLbl.text = Localize("addMoney.newDesign.bankaccount.bic")
        accountNumberLbl.text = Localize("addMoney.newDesign.bankaccount.accountNumber")
        accountNameLbl.text = Localize("addMoney.newDesign.bankaccount.accountName")
        bankAddressLbl.text = Localize("addMoney.newDesign.bankaccount.bankAddress")
        purposeOfPaymentLbl.text = Localize("addMoney.newDesign.bankaccount.purpose")
        companyAddressLbl.text = Localize("addMoney.newDesign.bankaccount.companyAddress")
        
//        emailButton.setTitle(Localize("addMoney.newDesign.bankaccount.emailMe"), for: UIControlState.normal)
//        nextButton.setTitle(Localize("addMoney.newDesign.bankaccount.next"), for: UIControlState.normal)
    }

    
    @IBAction func backAction(_ sender: UITapGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func nextAction(_ sender: UIButton) {
        
//        let parentVC = self.parent as! LWAddMoneyViewController
//        parentVC.nextAction(sender)
    }
    
    @IBAction func copyBIC() {
        UIPasteboard.general.string = bicLabel.text
        makeToast(.bic)
    }

    @IBAction func copyAccountNumber() {
        UIPasteboard.general.string = accountNumberLabel.text
        makeToast(.accountNumber)
    }
    
    @IBAction func copyAccountName() {
        UIPasteboard.general.string = accountNameLabel.text
        makeToast(.accountName)
    }
    
    @IBAction func copyBankAddress() {
        UIPasteboard.general.string = bankAddressLabel.text
        makeToast(.bankAddress)
    }
    
    @IBAction func copyCompanyAddress() {
        UIPasteboard.general.string = companyAddressLabel.text
        makeToast(.companyAddress)
    }
    
    @IBAction func copyPaymentPurpose() {
        UIPasteboard.general.string = purposeOfPaymentLabel.text
        makeToast(.paymentPurpose)
    }
    
    private func makeToast(_ bankData: BankData) {
        let toastMessage = String(format: "%@ %@.",
                                  Localize(bankData.rawValue),
                                  Localize("receive.newDesign.copyToast")?.lowercased() ?? "")
        self.view.makeToast(toastMessage)
    }
}

fileprivate extension SwiftCredentialsViewModel {
    func bind(toViewController vc: BankViewController) -> [Disposable] {
        #if TEST
            return [
                bic.drive(vc.bicLabel.rx.text),
                Driver.just("XXXX XXXX XXXX").drive(vc.accountNumberLabel.rx.text),
                accountName.drive(vc.accountNameLabel.rx.text),
                purposeOfPayment.drive(vc.purposeOfPaymentLabel.rx.text),
                bankAddress.drive(vc.bankAddressLabel.rx.text),
                companyAddress.drive(vc.companyAddressLabel.rx.text),
                loadingViewModel.isLoading.bind(to: vc.rx.loading),
                errors.drive(vc.rx.error)
            ]
        #else
            return [
                bic.drive(vc.bicLabel.rx.text),
                accountNumber.drive(vc.accountNumberLabel.rx.text),
                accountName.drive(vc.accountNameLabel.rx.text),
                purposeOfPayment.drive(vc.purposeOfPaymentLabel.rx.text),
                bankAddress.drive(vc.bankAddressLabel.rx.text),
                companyAddress.drive(vc.companyAddressLabel.rx.text),
                loadingViewModel.isLoading.bind(to: vc.rx.loading),
                errors.drive(vc.rx.error)
            ]
        #endif
    }
}
