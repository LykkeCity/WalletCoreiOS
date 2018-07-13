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
    @IBOutlet fileprivate weak var accountHolderCountryTextField: UITextField!
    @IBOutlet fileprivate weak var accountHolderCountryCodeTextField: UITextField!
    @IBOutlet fileprivate weak var accountHolderZipCodeTextField: UITextField!
    @IBOutlet fileprivate weak var accountHolderCityTextField: UITextField!

    @IBOutlet fileprivate weak var nextButton: UIButton!
    
    var cashOutViewModel: CashOutViewModel!
    
    fileprivate let disposeBag = DisposeBag()

    fileprivate var selectedCountry: LWCountryModel? {
        didSet {
            guard let country = selectedCountry else {
                return
            }
            cashOutViewModel.bankAccountViewModel.accountHolderCountry.value = country.name
        }
    }
    
    private let selectCountryViewModel = SelectCountryViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        localize()
        
        cashOutViewModel.bankAccountViewModel.bind(self)
        
        setupFormUX(disposedBy: disposeBag)
    }
    
    private func localize(){
        subtitleLabel.text = Localize("cashOut.newDesign.inputBankAccountDetails")
        accountNameTextField.placeholder = Localize("cashOut.newDesign.bankName")
        ibanTextField.placeholder = Localize("cashOut.newDesign.iban")
        bicTextField.placeholder = Localize("cashOut.newDesign.bic")
        accountHolderTextField.placeholder = Localize("cashOut.newDesign.accountHolder")
        currencyTextField.placeholder = Localize("cashOut.newDesign.accountHolderAddress")
        accountHolderCountryTextField.placeholder = Localize("cashOut.newDesign.accountHolderCountry")
        accountHolderCountryCodeTextField.placeholder = Localize("cashOut.newDesign.accountHolderCountryCode")
        accountHolderZipCodeTextField.placeholder = Localize("cashOut.newDesign.accountHolderZipCode")
        accountHolderCityTextField.placeholder = Localize("cashOut.newDesign.accountHolderCity")
        nextButton.setTitle(Localize("newDesign.next"), for: .normal)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NextStep" {
            guard let vc = segue.destination as? CashOutConfirmationViewController else { return }
            vc.cashOutViewModel = cashOutViewModel
        }
        
        if segue.identifier == "SelectCountry" {
            guard
                let navController = segue.destination as? UINavigationController,
                let vc = navController.viewControllers.first as? SelectCountryViewController
                else {
                    return
            }
            vc.viewModel = selectCountryViewModel
            vc.selectedCountry = selectedCountry ?? selectCountryViewModel.countryBy(name: accountHolderCountryTextField.text)
            vc.delegate = self
        }
    }

}

fileprivate extension CashOutBankAccountViewModel {
    func bind(_ viewController: CashOurBankAccountDetailsViewController) {
        (viewController.accountNameTextField.rx.textInput <-> bankName)
            .disposed(by: viewController.disposeBag)
        
        (viewController.ibanTextField.rx.textInput <-> iban)
            .disposed(by: viewController.disposeBag)
        
        (viewController.bicTextField.rx.textInput <-> bic)
            .disposed(by: viewController.disposeBag)
        
        (viewController.accountHolderTextField.rx.textInput <-> accountHolder)
            .disposed(by: viewController.disposeBag)
        
        (viewController.currencyTextField.rx.textInput <-> accountHolderAddress)
            .disposed(by: viewController.disposeBag)
        
        (viewController.accountHolderCountryTextField.rx.textInput <-> accountHolderCountry)
            .disposed(by: viewController.disposeBag)
        
        (viewController.accountHolderCountryCodeTextField.rx.textInput <-> accountHolderCountryCode)
            .disposed(by: viewController.disposeBag)
        
        (viewController.accountHolderZipCodeTextField.rx.textInput <-> accountHolderZipCode)
            .disposed(by: viewController.disposeBag)
        
        (viewController.accountHolderCityTextField.rx.textInput <-> accountHolderCity)
            .disposed(by: viewController.disposeBag)
        
        let isFormValidDriver = isValid.asDriver(onErrorJustReturn: false)
        
        isFormValidDriver
            .drive(viewController.nextButton.rx.isEnabled)
            .disposed(by: viewController.disposeBag)
    }
}

extension CashOurBankAccountDetailsViewController: SelectCountryViewControllerDelegate {
    
    func controller(_ controller: SelectCountryViewController, didSelectCountry country: LWCountryModel) {
        self.selectedCountry = country
        controller.dismiss(animated: true)
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
            currencyTextField,
            accountHolderCountryCodeTextField,
            accountHolderZipCodeTextField,
            accountHolderCityTextField
        ]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return goToTextField(after: textField)
    }
    
}
