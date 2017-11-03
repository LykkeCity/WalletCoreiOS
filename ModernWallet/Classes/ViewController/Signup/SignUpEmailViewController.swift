//
//  SignUpEmailViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 6/12/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import RxSwift
import RxCocoa
import TextFieldEffects

class SignUpEmailViewController: UIViewController, UIGestureRecognizerDelegate {
    

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var subTitleConstraint: NSLayoutConstraint!

    private let disposeBag = DisposeBag()
    
    lazy var accountExistsViewModel: AccountExistViewModel = {
        return AccountExistViewModel(email: self.emailTextField.rx.text.asObservable().filterNil())
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.subscribeKeyBoard(withDisposeBag: disposeBag)
        // Do any additional setup after loading the view.
        signInButton.setTitle(Localize("auth.newDesign.signin"), for: UIControlState.normal)
        
        accountExistsViewModel.accountExistObservable
            .do(onNext: { $0.saveValues() })
            .map{$0.isRegistered ? "auth.newDesign.signin" : "auth.newDesign.signup"}
            .subscribe(onNext: { [weak self] buttonTitle in
                self?.signInButton.setTitle(Localize(buttonTitle), for: UIControlState.normal)
            })
            .disposed(by: disposeBag)
        
        accountExistsViewModel.isLoading
            .map{!$0}
            .bind(to: signInButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        let isValidEmail = emailTextField.rx.text.asObservable()
            .replaceNilWith("")
            .map{LWValidator.validateEmail($0)}
            
        isValidEmail
            .bind(to: signInButton.rx.isEanbledWithBorderColor)
            .disposed(by: disposeBag)
        
        signInButton.rx.tap.asObservable()
            .withLatestFrom(accountExistsViewModel.accountExistObservable)
            .map{$0.isRegistered ? "SignInSegue" : "SignUpSegue"}
            .subscribe(onNext: {[weak self] segueId in
                self?.performSegue(withIdentifier: segueId, sender: nil)
            })
            .disposed(by: disposeBag)
        
        signInButton.rx.tap.asObservable()
            .subscribe(onNext: {[weak self] in
                self?.emailTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUserInterface()
    }

    func setUserInterface() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
//        signInButton.setTitle(Localize("auth.newDesign.signin"), for: UIControlState.normal)
//        signUpButton.setTitle(Localize("auth.newDesign.signup"), for: UIControlState.normal)
        
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
        
        emailTextField.delegate = self
        emailTextField.placeholder = Localize("auth.newDesign.email")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "SignInSegue" {
            let signUpPasswordVC = segue.destination as! SignUpPasswordViewController
            signUpPasswordVC.email = emailTextField.text ?? ""
        }
        
        if segue.identifier == "SignUpSegue" {
            let signUpPasswordVC = segue.destination as! RegisterConfrimEmailViewController
            signUpPasswordVC.emailConfirmString = emailTextField.text ?? ""
        }
    }
}

extension SignUpEmailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if signInButton.isEnabled {
            signInButton.sendActions(for: .touchUpInside)
        }
        
        return true
    }
}
