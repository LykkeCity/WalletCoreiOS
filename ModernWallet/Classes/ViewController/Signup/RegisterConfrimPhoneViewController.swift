//
//  RegisterConfrimPhoneViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 9/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import RxCocoa
import RxSwift
import TextFieldEffects

class RegisterConfrimPhoneViewController: UIViewController {

    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var codeNumberTextField: HoshiTextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var resendPinButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    private let triggerButton = UIButton()
    var signInFlag: Bool = false
    var phone = ""
    
    
    lazy var viewModel : SignUpPhoneConfirmPinViewModel={
        return SignUpPhoneConfirmPinViewModel(submitConfirmPin: self.confirmButton.rx.tap.asObservable(), submitResendPin: self.resendPinButton.rx.tap.asObservable() )
    }()
    
    lazy var clientCodes:ClientCodesViewModel = {
        return ClientCodesViewModel(
            trigger: self.triggerButton.rx.tap.asObservable(),
            dependency: (
                authManager: LWRxAuthManager.instance,
                keychainManager: LWKeychainManager.instance()
            )
        )
    }()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if signInFlag {
            titleLabel.text = "Please verify your login with an SMS code"
        }

        getClientCode()
        
        // Do any additional setup after loading the view.
        scrollView.subscribeKeyBoard(withDisposeBag: disposeBag)
        
        // Do any additional setup after loading the view.
        codeNumberTextField.rx.text
            .map({$0 ?? ""})
            .bind(to: viewModel.pin)
            .disposed(by: disposeBag)
       
        
        viewModel.isValid
            .bind(to: confirmButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.phone.value = phone
        
        viewModel.loading.subscribe(onNext: {isLoading in
            self.confirmButton.isEnabled = !isLoading
            self.resendPinButton.isEnabled = !isLoading
            if(isLoading == false)
            {
                self.viewModel.pin.value = self.viewModel.pin.value
            }
        }).disposed(by: disposeBag)
        
        viewModel.resultConfirmPin.asObservable()
            .filterError()
            .subscribe(onNext: {[weak self] errorData in
                self?.show(error: errorData)
            })
            .disposed(by: disposeBag)
        
        viewModel.resultConfirmPin.asObservable()
            .filterSuccess()
            .subscribe(onNext: {pack in
                if(pack.isPassed == true)
                {
                    print("Pin code during registration match")
                    //self.goToNextScreen()
                    self.goToNextScreen()
                }
                else{
                    let alertController = UIAlertController(title: Localize("utils.error"), message: Localize("register.sms.error"), preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: Localize("utils.ok"), style: UIAlertActionStyle.default) {
                        (result : UIAlertAction) -> Void in
                        print("OK")
                    }
                    
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                print("IsPassed: ", pack.isPassed)
            })
            .disposed(by: disposeBag)
        
        //resend pin
        viewModel.resultResendPin.asObservable()
            .filterError()
            .subscribe(onNext: {[weak self] errorData in
                self?.view.makeToast("Error")
                
            })
            .disposed(by: disposeBag)
        
        viewModel.resultResendPin.asObservable()
            .filterSuccess()
            .subscribe(onNext: {pack in
                //success resend pin
                
            })
            .disposed(by: disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func goToNextScreen() {
        
        if !signInFlag {
            let signInStoryBoard = UIStoryboard.init(name: "SignIn", bundle: nil)
            
            let signUpRegisterCreatePinVC = signInStoryBoard.instantiateViewController(withIdentifier: "SignUpCreatePin") as! RegisterCreatePinViewController
            
            self.view.endEditing(true)
            self.navigationController?.pushViewController(signUpRegisterCreatePinVC, animated: true)
        }
        else {
//            dismisVC()
            self.triggerButton.sendActions(for: .touchUpInside)
        }
        
    }
    
    func dismisVC() {
        UserDefaults.standard.set("true", forKey: "loggedIn")
        dismiss(animated: true) {
            NotificationCenter.default.post(name: .loggedIn, object: nil)
            print("Current screen is down")
        }
    }
    
    @IBAction func backAction(_ sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func getClientCode() {
        
        clientCodes.errors
            .subscribe(onNext: {[weak self] error in
                guard let `self` = self else {return}
                self.show(error: error)
            })
            .disposed(by: disposeBag)
        
        clientCodes.encodeMainKeyObservable
            .subscribe(onNext: {[weak self] result in
                self?.dismisVC()
            })
            .disposed(by: disposeBag)
        
        clientCodes.loadingViewModel.isLoading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
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
