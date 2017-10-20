//
//  RegisterCreatePasswordViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 8/31/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import RxSwift
import RxCocoa
import TextFieldEffects

class RegisterCreatePasswordViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    @IBOutlet weak var reenterPassTextFiel: HoshiTextField!
    
    var email = ""
    @IBOutlet weak var nextButton: UIButton!
    
    lazy var viewModel : SignUpRegistrationViewModel={
        return SignUpRegistrationViewModel(submit: self.nextButton.rx.tap.asObservable() )
    }()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.subscribeKeyBoard(withDisposeBag: disposeBag)
        
        passwordTextField.rx.text
            .map({$0 ?? ""})
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
        reenterPassTextFiel.rx.text
            .map({$0 ?? ""})
            .bind(to: viewModel.reenterPassword)
            .disposed(by: disposeBag)
        
        viewModel.isValid
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        changeStateOfButton()
        setUserInterface()
        
        Timer.scheduledTimer(timeInterval: 0.1,
                             target: self,
                             selector: #selector(self.changeStateOfButton),
                             userInfo: nil,
                             repeats: true)
    }
    
    func setUserInterface() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        
        nextButton.layer.borderWidth = 1.0
        nextButton.setTitle(Localize("auth.newDesign.next"), for: UIControlState.normal)
        changeStateOfButton()
        
        Timer.scheduledTimer(timeInterval: 0.1,
                             target: self,
                             selector: #selector(self.changeStateOfButton),
                             userInfo: nil,
                             repeats: true)
    }
    
    func changeStateOfButton() {
        
        if nextButton.isEnabled
        {
            nextButton.layer.borderColor = UIColor.white.cgColor
        }
        else
        {
            nextButton.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    @IBAction func backAction(_ sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    @IBAction func goToNextScreen(_ sender:UIButton) {
        
        let signInStoryBoard = UIStoryboard.init(name: "SignIn", bundle: nil)
        
        let signUpRegisterHintVC = signInStoryBoard.instantiateViewController(withIdentifier: "SignUpHint") as! RegisterHintViewController

        signUpRegisterHintVC.email = email
        signUpRegisterHintVC.password = self.passwordTextField.text!
        self.view.endEditing(true)
        self.navigationController?.pushViewController(signUpRegisterHintVC, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
