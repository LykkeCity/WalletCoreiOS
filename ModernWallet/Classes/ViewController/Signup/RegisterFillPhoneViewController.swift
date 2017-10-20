//
//  RegisterFillPhoneViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 9/6/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import RxCocoa
import RxSwift
import TextFieldEffects

class RegisterFillPhoneViewController: UIViewController {

    @IBOutlet weak var phoneNumberTextField: HoshiTextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    lazy var viewModel : PhoneNumberViewModel={
        return PhoneNumberViewModel(saveSubmit: self.confirmButton.rx.tap.asObservable() )
    }()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrollView.subscribeKeyBoard(withDisposeBag: disposeBag)
        
        // Do any additional setup after loading the view.
        phoneNumberTextField.rx.text
            .map({$0 ?? ""})
            .bind(to: viewModel.phonenumber)
            .disposed(by: disposeBag)
        
        
        
        //from the viewModel
        viewModel.isValid
            .bind(to: confirmButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.loading.subscribe(onNext: {isLoading in
            self.confirmButton.isEnabled = !isLoading
        }).disposed(by: disposeBag)
        
        viewModel.loadingSaveChanges.subscribe(onNext: {isLoading in
            self.confirmButton.isEnabled = !isLoading
        }).disposed(by: disposeBag)
        
        
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
        
        //////////// load contry codes
        
        viewModel.countryCodesResult.asObservable()
            .filterSuccess()
            .subscribe(onNext: {packet in
                //list LWPacketCountryCodes
                
            })
            .disposed(by: disposeBag)
    }

    func goToNextScreen() {
        
        let signInStoryBoard = UIStoryboard.init(name: "SignIn", bundle: nil)
        
        let signUpRegisterConfrimPhoneVC = signInStoryBoard.instantiateViewController(withIdentifier: "SignUpConfrimPhone") as! RegisterConfrimPhoneViewController
        signUpRegisterConfrimPhoneVC.phone = self.phoneNumberTextField.text!
        self.view.endEditing(true)
        self.navigationController?.pushViewController(signUpRegisterConfrimPhoneVC, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
