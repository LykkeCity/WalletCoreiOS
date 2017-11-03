//
//  SignInPinViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 6/13/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import RxSwift
import RxCocoa

class SignUpPinViewController: UIViewController, PinViewControllerDelegate {
    
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var subTitleConstraint: NSLayoutConstraint!
    @IBOutlet weak var forgotPinButton: UIButton!
    @IBOutlet weak var pinCodeView: UIView!
    
    private let disposeBag = DisposeBag()
    private let triggerButton = UIButton()
    private let triggerSmsButton = UIButton()
    private var pinViewController:PinViewController? = nil
    
    lazy var clientCodes:ClientCodesViewModel = {
        return ClientCodesViewModel(
            trigger: self.triggerButton.rx.tap.asObservable(),
            dependency: (
                authManager: LWRxAuthManager.instance,
                keychainManager: LWKeychainManager.instance()
            )
        )
    }()
    
    lazy var viewModel : PhoneNumberViewModel={
        return PhoneNumberViewModel(saveSubmit: self.triggerSmsButton.rx.tap.asObservable() )
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        clientCodes.errors
            .subscribe(onNext: {[weak self] error in
                guard let `self` = self else {return}
                self.show(error: error)
            })
            .disposed(by: disposeBag)

        embedPinViewController()
//        getClientCode()
        sendSMS()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUserInterface()
    }
    
    func setUserInterface() {
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
        
        forgotPinButton.setTitle(Localize("auth.newDesign.forgotPin"), for: UIControlState.normal)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

       
    
    func createPrivateKey() {
        guard let privateKeyManager = LWPrivateKeyManager.shared() else {return}
        guard privateKeyManager.isPrivateKeyLykkeEmpty() else {return}
        
        privateKeyManager.savePrivateKeyLykke(fromSeedWords: LWPrivateKeyManager.generateSeedWords12())

        LWAuthManager.instance()?.requestSaveClientKeys(
            withPubKey: privateKeyManager.publicKeyLykke,
            encodedPrivateKey: privateKeyManager.encryptedKeyLykke
        )
    }
    
    func getClientCode() {
        
        clientCodes.encodeMainKeyObservable
            .subscribe(onNext: {[weak self] result in
          self?.dismisVC()
        })
        .disposed(by: disposeBag)
        
        clientCodes.loadingViewModel.isLoading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
        clientCodes.loadingViewModel.isLoading.subscribe(onNext: {[weak self] isLoading in
            self?.pinViewController?.removeAllPins()
        }).disposed(by: disposeBag)
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
    
    func embedPinViewController() {
        
        
        let signInStoryBoard = UIStoryboard.init(name: "SignIn", bundle: nil)
        pinViewController = signInStoryBoard.instantiateViewController(withIdentifier: "PinViewController") as? PinViewController
        pinViewController?.twoVerifications = false
        pinViewController?.isTouchIdHidden = true //LWKeychainManager.instance()?.pin()?.isEmpty ?? true // hide touch id if the pin is empty
        pinViewController?.delegate = self
        pinViewController?.view.frame = pinCodeView.bounds
        pinCodeView.addSubview((pinViewController?.view)!)
    }

    // MARK: - PIN Delegate
    func isPinCorrect(_ success: Bool, pinController: PinViewController) {
        if success {
            //            dismisVC()
            //            self.triggerButton.sendActions(for: .touchUpInside)
            guard let privateKeyManager = LWPrivateKeyManager.shared() else {return}
            if privateKeyManager.isPrivateKeyLykkeEmpty() {
                 self.triggerSmsButton.sendActions(for: .touchUpInside)
            } else {
                dismisVC()
            }
        }
    }
    
    func isTouchIdCorrect(_ success: Bool, pinController: PinViewController ) {
        if success {
            //            dismisVC()
            //            self.triggerButton.sendActions(for: .touchUpInside)
            
            guard let privateKeyManager = LWPrivateKeyManager.shared() else {return}
            if privateKeyManager.isPrivateKeyLykkeEmpty() {
               self.triggerSmsButton.sendActions(for: .touchUpInside)
            } else {
                dismisVC()
            }
        }
    }
    
    func goToNextScreen() {
        
        guard let keychainManager = LWKeychainManager.instance() else {return}
        guard let personalData = keychainManager.personalData() else {return}
        
        let signInStoryBoard = UIStoryboard.init(name: "SignIn", bundle: nil)
        
        let signUpRegisterConfrimPhoneVC = signInStoryBoard.instantiateViewController(withIdentifier: "SignUpConfrimPhone") as! RegisterConfrimPhoneViewController
        signUpRegisterConfrimPhoneVC.phone = personalData.phone
        signUpRegisterConfrimPhoneVC.signInFlag = true
        self.view.endEditing(true)
        self.navigationController?.pushViewController(signUpRegisterConfrimPhoneVC, animated: true)
        
    }
    
    func sendSMS() {
        
        guard let keychainManager = LWKeychainManager.instance() else {return}
        guard let personalData = keychainManager.personalData() else {return}
        
        let phoneVariable = Variable<String>("")
        phoneVariable.value = personalData.phone
        
        phoneVariable.asObservable()
            .bind(to: viewModel.phonenumber)
            .disposed(by: disposeBag)
        
        viewModel.saveSettingsResult.asObservable()
            .filterError()
            .subscribe(onNext: {[weak self] errorData in
                self?.show(error: errorData)
            })
            .disposed(by: disposeBag)
        
        viewModel.saveSettingsResult.asObservable()
            .filterSuccess()
            .subscribe(onNext: {pack in
                //success
                self.goToNextScreen()
            })
            .disposed(by: disposeBag)
    }
}


