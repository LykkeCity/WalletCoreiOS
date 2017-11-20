//
//  CashOurBankAccountDetailsViewController.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 25.10.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class CashOurBankAccountDetailsViewController: UIViewController {

    @IBOutlet internal weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet fileprivate weak var accountNameTextField: UITextField!
    @IBOutlet fileprivate weak var ibanTextField: UITextField!
    @IBOutlet fileprivate weak var bicTextField: UITextField!
    @IBOutlet fileprivate weak var accountHolderTextField: UITextField!
    @IBOutlet fileprivate weak var currencyTextField: UITextField!

    @IBOutlet fileprivate weak var nextButton: UIButton!
    
    var cashOutViewModel: CashOutViewModel!
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        subtitleLabel.text = Localize("cashOut.newDesign.inputBankAccountDetails")
        accountNameTextField.placeholder = Localize("cashOut.newDesign.bankName")
        ibanTextField.placeholder = Localize("cashOut.newDesign.iban")
        bicTextField.placeholder = Localize("cashOut.newDesign.bic")
        accountHolderTextField.placeholder = Localize("cashOut.newDesign.accountHolder")
        currencyTextField.placeholder = Localize("cashOut.newDesign.accountHolderAddress")
        nextButton.setTitle(Localize("newDesign.next"), for: .normal)
        
        let bankDetailsViewModel = cashOutViewModel.bankAccountViewModel
        
        (accountNameTextField.rx.textInput <-> bankDetailsViewModel.bankName)
            .disposed(by: disposeBag)
        
        (ibanTextField.rx.textInput <-> bankDetailsViewModel.iban)
            .disposed(by: disposeBag)
        
        (bicTextField.rx.textInput <-> bankDetailsViewModel.bic)
            .disposed(by: disposeBag)
        
        (accountHolderTextField.rx.textInput <-> bankDetailsViewModel.accountHolder)
            .disposed(by: disposeBag)
        
        (currencyTextField.rx.textInput <-> bankDetailsViewModel.accountHolderAddress)
            .disposed(by: disposeBag)
        
        let isFormValidDriver = bankDetailsViewModel.isValid.asDriver(onErrorJustReturn: false)
        
        isFormValidDriver
            .drive(nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        setupFormUX(disposedBy: disposeBag)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NextStep" {
            guard let vc = segue.destination as? CashOutConfirmationViewController else { return }
            vc.cashOutViewModel = cashOutViewModel
        }
    }

}

extension CashOurBankAccountDetailsViewController: InputForm {
    
    var submitButton: UIButton! {
        return nextButton
    }
    
    var textFields: [UITextField] {
        return [
            accountNameTextField,
            ibanTextField,
            bicTextField,
            accountHolderTextField,
            currencyTextField
        ]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return goToTextField(after: textField)
    }
    
}
