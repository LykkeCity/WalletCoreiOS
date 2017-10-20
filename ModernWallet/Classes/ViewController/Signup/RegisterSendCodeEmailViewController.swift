//
//  RegisterSendCodeEmailViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 8/30/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import RxSwift
import RxCocoa
import TextFieldEffects

class RegisterSendCodeEmailViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pinCodeTextField: HoshiTextField!
    @IBOutlet weak var confrimButton: UIButton!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var subTitleLbl: UILabel!
    var emailString = ""
    
    lazy var viewModel : RegisterSendPinEmailViewModel={
        return RegisterSendPinEmailViewModel(submitConfirmPin: self.confrimButton.rx.tap.asObservable(), submitResendPin: self.resendButton.rx.tap.asObservable() )
    }()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.subscribeKeyBoard(withDisposeBag: disposeBag)
        
        pinCodeTextField.rx.text
            .map({$0 ?? ""})
            .bind(to: viewModel.pin)
            .disposed(by: disposeBag)
        
        viewModel.isValid
            .bind(to: confrimButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.email.value = emailString
        
        viewModel.loading.subscribe(onNext: {isLoading in
            self.confrimButton.isEnabled = !isLoading
            self.resendButton.isEnabled = !isLoading
          
        }).disposed(by: disposeBag)
        
        viewModel.resultConfirmPin.asObservable()
            .filterError()
            .subscribe(onNext: {[weak self] errorData in
                self?.show(error: errorData)
            })
            .disposed(by: disposeBag)
        
        viewModel.resultConfirmPin.asObservable()
            .filterSuccess()
            .subscribe(onNext: {[weak self] pack in
                if(pack.isPassed == true)
                {
                    print("Pin code during registration match")
                    self?.goToNextScreen()
                }
                else{
                    let alertController = UIAlertController(title: Localize("utils.error"), message: Localize("register.sms.error"), preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: Localize("utils.ok"), style: UIAlertActionStyle.default) {
                        (result : UIAlertAction) -> Void in
                        print("OK")
                    }
                    
                    alertController.addAction(okAction)
                    self?.present(alertController, animated: true, completion: nil)
                }
                print("IsPassed: ", pack.isPassed)
            })
            .disposed(by: disposeBag)
        
        //resend pin
        viewModel.resultResendPin.asObservable()
            .filterError()
            .subscribe(onNext: {[weak self] errorData in
                if let message = errorData["Message"] as? String {
                    self?.view.makeToast(message)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.resultResendPin.asObservable()
            .filterSuccess()
            .subscribe(onNext: {[weak self] pack in
                //success resend pin
                self?.view.makeToast(Localize("Success resent pin"))
            })
            .disposed(by: disposeBag)
        
        
        // Do any additional setup after loading the view.
        setUserInterface()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(_ sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
       
    }
    
    func setUserInterface() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        subTitleLbl.text = " We've sent the code to your email address " + emailString
        pinCodeTextField.keyboardType = .numberPad
        
        confrimButton.layer.borderWidth = 1.0
        confrimButton.setTitle(Localize("auth.newDesign.confirm"), for: UIControlState.normal)
        changeStateOfButton()
        
        Timer.scheduledTimer(timeInterval: 0.1,
                             target: self,
                             selector: #selector(self.changeStateOfButton),
                             userInfo: nil,
                             repeats: true)
    }
    
    func changeStateOfButton() {
        
        if confrimButton.isEnabled
        {
            confrimButton.layer.borderColor = UIColor.white.cgColor
        }
        else
        {
            confrimButton.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    func goToNextScreen() {
        let signInStoryBoard = UIStoryboard.init(name: "SignIn", bundle: nil)
        
        let signUpRegisterCreatePasswordVC = signInStoryBoard.instantiateViewController(withIdentifier: "SignUpCreatePassword") as! RegisterCreatePasswordViewController
        signUpRegisterCreatePasswordVC.email = emailString
//        emailTextField.resignFirstResponder()
        self.view.endEditing(true)
        self.navigationController?.pushViewController(signUpRegisterCreatePasswordVC, animated: true)
        
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
