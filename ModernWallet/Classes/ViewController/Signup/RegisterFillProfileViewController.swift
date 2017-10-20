//
//  RegisterFillProfileViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 9/4/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import RxCocoa
import RxSwift
import TextFieldEffects

class RegisterFillProfileViewController: UIViewController {

    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstNameTextField: HoshiTextField!
    @IBOutlet weak var lastNameTextField: HoshiTextField!
    @IBOutlet weak var nextButton: UIButton!

    lazy var viewModel : ClientFullNameSetViewModel={
       return ClientFullNameSetViewModel(trigger: self.nextButton.rx.tap.asObservable())
    }()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrollView.subscribeKeyBoard(withDisposeBag: disposeBag)
        setFullName()
    }

    func setFullName() {
        
        firstNameTextField.rx.text
            .map({$0 ?? ""})
            .bind(to: viewModel.firstName)
            .disposed(by: disposeBag)
        
        lastNameTextField.rx.text
            .map({$0 ?? ""})
            .bind(to: viewModel.lastName)
            .disposed(by: disposeBag)
        
        viewModel.isValid
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        
        viewModel.clientFullNameSet
            .subscribe(onNext: {[weak self] result in
                self?.goToNextScreen()
            })
            .disposed(by: disposeBag)
        
        viewModel.loadingViewModel.isLoading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(_ sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    func goToNextScreen() {
        let signInStoryBoard = UIStoryboard.init(name: "SignIn", bundle: nil)
        
        let signUpRegisterFillPhoneVC = signInStoryBoard.instantiateViewController(withIdentifier: "SignUpFillPhone") as! RegisterFillPhoneViewController
        
        self.view.endEditing(true)
        self.navigationController?.pushViewController(signUpRegisterFillPhoneVC, animated: true)
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
