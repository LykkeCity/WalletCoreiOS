//
//  AddMoneyCCViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 6/28/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import RxSwift
import RxCocoa
import TextFieldEffects
import RxKeyboard

class AddMoneyCCStep1ViewController: AddMoneyBaseViewController {
    
    @IBOutlet weak var assetCode: UILabel!
    @IBOutlet weak var assetSymbol: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var ccContainerView: UIView!
    @IBOutlet weak var amauntField: UITextField!
    @IBOutlet weak var firstNameField: LimitedHoshiTextField!
    @IBOutlet weak var lastNameField: LimitedHoshiTextField!
    @IBOutlet weak var addressField: LimitedHoshiTextField!
    @IBOutlet weak var cityField: LimitedHoshiTextField!
    @IBOutlet weak var zipField: LimitedHoshiTextField!
    @IBOutlet weak var countryField: HoshiTextField!
    @IBOutlet weak var codeField: HoshiTextField!
    @IBOutlet weak var phoneField: HoshiTextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
        
    private lazy var creditCardViewModel:CreditCardBaseInfoViewModel = {
        return CreditCardBaseInfoViewModel(submit: self.submitButton.rx.tap.confirm(vc: self),
                                           assetToAdd: self.аssetObservable())
    }()
    
    fileprivate var selectedCountry: LWCountryModel? {
        didSet {
            guard let country = selectedCountry else {
                return
            }
            creditCardViewModel.input.country.value = country.name
        }
    }
    
    private let selectCountryViewModel = SelectCountryViewModel()
    
    fileprivate let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clear
        
        ccContainerView.layer.borderWidth = 1.0
        ccContainerView.layer.borderColor = UIColor.white.cgColor
        ccContainerView.layer.cornerRadius = 10.0
        
        creditCardViewModel.bindToFormFields(self)
        creditCardViewModel.bindToAsset(self)
        creditCardViewModel.bindToPaymentUrl(self)
        creditCardViewModel.driveErrors(self)
        
        creditCardViewModel.loadingViewModel.isLoading
            .bind(to: self.rx.loading)
            .disposed(by: disposeBag)
        
        creditCardViewModel.loadingViewModel.isLoading.map{!$0}
            .bind(to: submitButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        //add buttons above of the keyboard for these type of keyboards that don't have return button, 
        //and call textFieldShouldReturn on button tap
        setupFormUX(disposedBy: disposeBag)
    }

    
    func setUserInterface() {
//        amountToAddLabel.text = Localize("addMoney.newDesign.creditcard.amountToAdd")
//        ccNumberLabel.text = Localize("addMoney.newDesign.creditcard.ccNumber")
//        ccHolderNameLabel.text = Localize("addMoney.newDesign.creditcard.ccHolderName")
//        ccExpiryLabel.text = Localize("addMoney.newDesign.creditcard.ccExpiry")
//        cvcumberLabel.text = Localize("addMoney.newDesign.creditcard.cvcNumber")
//        
//        submitBtn.setTitle(Localize("addMoney.newDesign.creditcard.submit"), for: UIControlState.normal)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectCountry" {
            guard
                let navController = segue.destination as? UINavigationController,
                let vc = navController.viewControllers.first as? SelectCountryViewController
            else {
                return
            }
            vc.viewModel = selectCountryViewModel
            vc.selectedCountry = selectedCountry ?? selectCountryViewModel.countryBy(name: countryField.text)
            vc.delegate = self
        }
    }

}

extension AddMoneyCCStep1ViewController: SelectCountryViewControllerDelegate {
    
    func controller(_ controller: SelectCountryViewController, didSelectCountry country: LWCountryModel) {
        self.selectedCountry = country
        controller.dismiss(animated: true)
    }
    
}

fileprivate extension CreditCardBaseInfoViewModel {
    
    func driveErrors(_ viewController: AddMoneyCCStep1ViewController) {
        errors.firstName.map{$0 != nil}
            .drive(viewController.firstNameField.rx.error)
            .disposed(by: viewController.disposeBag)
        
        errors.lastName.map{$0 != nil}
            .drive(viewController.lastNameField.rx.error)
            .disposed(by: viewController.disposeBag)
        
        errors.address.map{$0 != nil}
            .drive(viewController.addressField.rx.error)
            .disposed(by: viewController.disposeBag)
        
        errors.city.map{$0 != nil}
            .drive(viewController.cityField.rx.error)
            .disposed(by: viewController.disposeBag)
        
        errors.zip.map{$0 != nil}
            .drive(viewController.zipField.rx.error)
            .disposed(by: viewController.disposeBag)
        
        errors.country.map{$0 != nil}
            .drive(viewController.countryField.rx.error)
            .disposed(by: viewController.disposeBag)
        
        errors.phoneCode.map{$0 != nil}
            .drive(viewController.codeField.rx.error)
            .disposed(by: viewController.disposeBag)
        
        errors.phone.map{$0 != nil}
            .drive(viewController.phoneField.rx.error)
            .disposed(by: viewController.disposeBag)
        
        errors.errorMessage
            .drive(onNext: {[weak viewController] message in
                viewController?.view.makeToast(message)
            })
            .disposed(by: viewController.disposeBag)
    }
    
    func bindToPaymentUrl(_ viewController: AddMoneyCCStep1ViewController) {
        paymentUrlResult.filterSuccess()
            .subscribe(onNext: {[weak viewController] paymentUrl in
                guard let addMoneyCC2NVC = viewController?.storyboard?.instantiateViewController(withIdentifier: "addMoneyCC2NVC")
                    as? UINavigationController else {return}
                
                guard let addMoneyCC2VC = addMoneyCC2NVC.childViewControllers.first
                    as? AddMoneyCCStep2ViewController else {return}
                
                addMoneyCC2VC.paymentUrl = paymentUrl
                viewController?.navigationController?.parent?.present(addMoneyCC2NVC, animated: true, completion: nil)
            })
            .disposed(by: viewController.disposeBag)
    }
    
    func bindToAsset(_ viewController: AddMoneyCCStep1ViewController) {
        assetCode
            .drive(viewController.assetCode.rx.text)
            .disposed(by: viewController.disposeBag)
        
        assetSymbol
            .drive(viewController.assetSymbol.rx.text)
            .disposed(by: viewController.disposeBag)
    }
    
    func bindToFormFields(_ vc: AddMoneyCCStep1ViewController) {
        
        (vc.amountTextField.rx.textInput <-> input.amount)
            .disposed(by: vc.disposeBag)
        
        (vc.firstNameField.rx.textInput <-> input.firstName)
            .disposed(by: vc.disposeBag)
        
        (vc.lastNameField.rx.textInput <-> input.lastName)
            .disposed(by: vc.disposeBag)
        
        (vc.cityField.rx.textInput <-> input.city)
            .disposed(by: vc.disposeBag)
        
        (vc.zipField.rx.textInput <-> input.zip)
            .disposed(by: vc.disposeBag)
        
        (vc.addressField.rx.textInput <-> input.address)
            .disposed(by: vc.disposeBag)
        
        (vc.countryField.rx.textInput <-> input.country)
            .disposed(by: vc.disposeBag)
        
        (vc.codeField.rx.textInput <-> input.phoneCode)
            .disposed(by: vc.disposeBag)
        
        (vc.phoneField.rx.textInput <-> input.phone)
            .disposed(by: vc.disposeBag)
    }
}

extension AddMoneyCCStep1ViewController: InputForm {
    
    var textFields: [UITextField] {
        return [
            amountTextField,
            firstNameField,
            lastNameField,
            addressField,
            cityField,
            zipField,

        ]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return goToTextField(after: textField)
    }

}

fileprivate extension ObservableType where Self.E == Void {
    
    func confirm(vc: UIViewController?
        ) -> Observable<Void> {
        
        return flatMap{ [weak vc] _  -> Observable<Void> in
            guard let vc = vc else { return Observable<Void>.never() }
            return PinViewController.presentOrderPinViewController(from: vc, title: Localize("newDesign.enterPin"), isTouchIdEnabled: true)
        }
    }
}
