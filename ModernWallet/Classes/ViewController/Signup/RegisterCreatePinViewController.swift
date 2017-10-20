//
//  RegisterCreatePinViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 9/8/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import RxSwift
import RxCocoa

class RegisterCreatePinViewController: UIViewController, PinViewControllerDelegate {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var pinCodeView: UIView!
    private var pinViewController:PinViewController? = nil
    
    var triggerButton: UIButton = UIButton(type: UIButtonType.custom)
    
    
    lazy var viewModel : SignUpPinSetViewModel={
        return SignUpPinSetViewModel(submit: self.triggerButton.rx.tap.asObservable())
    }()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        textLabel.text = Localize("pin.create.new.title")
        embedPinViewController()
        sendPinToServer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(_ sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    func sendPinToServer() {

        viewModel.pin.value = (pinViewController?.myPin)!
        
        viewModel.result.asObservable()
            .filterError()
            .subscribe(onNext: { [weak self] errorData in
                self?.show(error: errorData)
            })
            .disposed(by: disposeBag)
        
        viewModel.result.asObservable()
            .filterSuccess()
            .subscribe(onNext: {[weak self] pack in
                
                //gonext
                if(!LWPrivateKeyManager.shared().isPrivateKeyLykkeEmpty())
                {
                    print("Success registration")
                    self?.dismiss(animated: true) {
                        UserDefaults.standard.set("true", forKey: "loggedIn")
                        print("user is logged in")
                    }
                }
                else{
                     self?.goToNextScreen()
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    func goToNextScreen() {
        
        let signInStoryBoard = UIStoryboard.init(name: "SignIn", bundle: nil)
        let signUpPasswordVC = signInStoryBoard.instantiateViewController(withIdentifier: "ShakeScreen") //as! PinSetViewController
        
        self.view.endEditing(true)
        self.navigationController?.pushViewController(signUpPasswordVC, animated: true)
    }

    func embedPinViewController() {
        
        let signInStoryBoard = UIStoryboard.init(name: "SignIn", bundle: nil)
        pinViewController = signInStoryBoard.instantiateViewController(withIdentifier: "PinViewController") as? PinViewController
        pinViewController?.twoVerifications = true
        pinViewController?.isTouchIdHidden = true
        pinViewController?.delegate = self
        pinViewController?.view.frame = pinCodeView.bounds
        pinCodeView.addSubview((pinViewController?.view)!)
        
    }
    
    
    // MARK: - PIN Delegate
    func isPinCorrect(_ success: Bool, pinController: PinViewController) {

        if success {
            viewModel.pin.value = (pinViewController?.myPin)!
            self.triggerButton.sendActions(for: .touchUpInside)
        }
    }
    
    func changeTextLabel(_ txtLabel: String?) {
        textLabel.text = txtLabel
    }

}

