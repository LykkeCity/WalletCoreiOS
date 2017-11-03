//
//  RegisterConfrimEmailViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 8/29/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import RxSwift
import RxCocoa
import TextFieldEffects


class RegisterConfrimEmailViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var confrimButton: UIButton!
    @IBOutlet weak var scrollVIew: UIScrollView!
    
    var emailConfirmString = ""
    var disposeBag = DisposeBag()
    
    lazy var viewModel : SignUpEmailViewModel={
        return SignUpEmailViewModel(submit: self.confrimButton.rx.tap.asObservable() )
    }()
    
    var gestureTap: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        changeStateOfButton()
        scrollVIew.subscribeKeyBoard(withDisposeBag: disposeBag)
        
        emailTextField.rx.text
            .map({$0 ?? ""})
            .bind(to: viewModel.email)
            .disposed(by: disposeBag)
        
        //from the viewModel
        viewModel.isValid
            .bind(to: confrimButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.loading.subscribe(onNext: {isLoading in
            self.confrimButton.isEnabled = !isLoading
        }).disposed(by: disposeBag)
        
        viewModel.result.asObservable()
            .filterError()
            .subscribe(onNext: {[weak self] errorData in
                self?.show(error: errorData)
            })
            .disposed(by: disposeBag)
        
        viewModel.result.asObservable()
            .filterSuccess()
            .subscribe(onNext: {[weak self] pack in
                self?.goToNextScreen()
            })
            .disposed(by: disposeBag)
        
        setUserInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.text = emailConfirmString
        emailTextField.becomeFirstResponder()
//        emailTextField.resignFirstResponder()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//         emailTextField.text = emailConfirmString
//    }

    func setUserInterface() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        emailTextField.keyboardType = .emailAddress

        confrimButton.layer.borderWidth = 1.0
        confrimButton.setTitle(Localize("auth.newDesign.confirm"), for: UIControlState.normal)

        
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
    
    @IBAction func backAction(_ sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goToNextScreen() {
        if emailConfirmString == emailTextField.text {
            let signInStoryBoard = UIStoryboard.init(name: "SignIn", bundle: nil)
            
            let signUpRegisterSendCodeVC = signInStoryBoard.instantiateViewController(withIdentifier: "SignUpSendCode") as! RegisterSendCodeEmailViewController
            signUpRegisterSendCodeVC.emailString = emailConfirmString
            emailTextField.resignFirstResponder()
            self.view.endEditing(true)
            self.navigationController?.pushViewController(signUpRegisterSendCodeVC, animated: true)
        }
        else {
           self.view.makeToast("Emails are not equal")
        }
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
