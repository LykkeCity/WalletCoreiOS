//
//  SignUpPasswordViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 6/13/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import RxSwift
import RxCocoa
import TextFieldEffects

class SignUpPasswordViewController: UIViewController {

    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    @IBOutlet weak var subTitleConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var email = ""
    var gestureTap: Bool = false
    private let disposeBag = DisposeBag()
    lazy var loginViewModel: LogInViewModel = {
        return LogInViewModel(submit: self.signInButton.rx.tap.asObservable())
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUserInterface()
        scrollView.subscribeKeyBoard(withDisposeBag: disposeBag)
        
        passwordTextField.delegate = self
        loginViewModel.email.value = email
        passwordTextField.rx.text.asObservable()
            .filterNil()
            .bind(to: loginViewModel.password)
            .disposed(by: disposeBag)
        
        loginViewModel.loading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
        loginViewModel.result.asObservable().filterError()
            .subscribe(onNext: {[weak self] error in
                self?.show(error: error)
            })
            .disposed(by: disposeBag)
        
        loginViewModel.result.asObservable().filterSuccess()
            .subscribe(onNext: {[weak self] packet in
                guard let `self` = self else {return}
                
                self.navigationController?.pushViewController(
                    (self.storyboard?.instantiateViewController(withIdentifier: "SignUpPinVC"))!,
                    animated: true
                )
            })
            .disposed(by: disposeBag)
        
        loginViewModel.isValid
            .bind(to: signInButton.rx.isEanbledWithBorderColor)
            .disposed(by: disposeBag)
        
        // Do any additional setup after loading the view.
    }
    
    func setUserInterface() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        signInButton.setTitle(Localize("auth.newDesign.signin"), for: UIControlState.normal)
        
        var fontSpace = 6.55
        
        if Display.typeIsLike == .iphone5 {
            fontSpace = 2.55
            subTitleConstraint.constant = 140.0
        } else if Display.typeIsLike == .iphone6plus {
            fontSpace = 8.05
            subTitleConstraint.constant = 175.0
        }
        
        let textLabel: NSMutableAttributedString = NSMutableAttributedString.init(string: Localize("auth.newDesign.subtitle"))
        textLabel.addAttribute(NSKernAttributeName, value:fontSpace, range: NSRange(location: 0, length: textLabel.length - 1))
        subTitleLabel.attributedText = textLabel
        passwordTextField.placeholder = Localize("auth.newDesign.password")
    }
    
    @IBAction func backAction(_ sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SignUpPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if signInButton.isEnabled {
            signInButton.sendActions(for: .touchUpInside)
        }
        
        return true
    }
}
