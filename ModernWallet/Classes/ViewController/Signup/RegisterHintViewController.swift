//
//  RegisterHintViewController.swift
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

class RegisterHintViewController: UIViewController {
    
    @IBOutlet weak var hintTextField: HoshiTextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var email = ""
    var password = ""
    @IBOutlet weak var nextButton: UIButton!
    
    lazy var viewModel : SignUpRegistrationViewModel={
        return SignUpRegistrationViewModel(submit: self.nextButton.rx.tap.asObservable(), partnerIdentifier: "LykkeModernMoney")
    }()
    
    var disposeBag = DisposeBag()
    
#if TEST
    var loadingViewModel: LoadingViewModel!
#endif

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrollView.subscribeKeyBoard(withDisposeBag: disposeBag)
        
        // Do any additional setup after loading the view.
        viewModel.clientInfo.value = LWDeviceInfo.instance().clientInfo()
        viewModel.email.value = self.email
        viewModel.password.value = self.password
        
        hintTextField.rx.text
            .map({$0 ?? ""})
            .bind(to: viewModel.hint)
            .disposed(by: disposeBag)
        
        viewModel.isValidHint
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.result.asObservable()
            .filterError()
            .subscribe(onNext: {[weak self] errorData in
                self?.show(error: errorData)
            })
            .disposed(by: disposeBag)
        
        #if TEST
            
        let allAssetRequest = viewModel.result.asObservable()
            .filterSuccess()
            .flatMap { _ in
                return LWRxAuthManager.instance.allAssets.request()
            }
            .shareReplay(1)
            
        let setBaseAssetRequest = allAssetRequest
            .filterSuccess()
            .map { (assets) in
                return assets.filter { $0.displayId == "USD" }.first?.identity ?? "USD"
            }
            .flatMap { assetId in
                LWRxAuthManager.instance.baseAssetSet.request(withParams: assetId)
            }
            .shareReplay(1)
            
        allAssetRequest
            .subscribe(onNext: {[weak self] pack in
                //gonext
                print("Success registration")
                self?.goToNextScreen()
            })
            .disposed(by: disposeBag)
            
        loadingViewModel = LoadingViewModel([viewModel.loading, allAssetRequest.isLoading(), setBaseAssetRequest.isLoading()])
        let loading = loadingViewModel.isLoading
            
        #else

        viewModel.result.asObservable()
            .filterSuccess()
            .subscribe(onNext: {[weak self] pack in
                //gonext
                print("Success registration")
                self?.goToNextScreen()
            })
            .disposed(by: disposeBag)
            
        let loading = viewModel.loading
            
        #endif

        loading.subscribe(onNext: {isLoading in
            self.nextButton.isEnabled = !isLoading
        }).disposed(by: disposeBag)
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
    
    func goToNextScreen() {
        
        let signInStoryBoard = UIStoryboard.init(name: "SignIn", bundle: nil)
        
        let signUpRegisterHintVC = signInStoryBoard.instantiateViewController(withIdentifier: "SignUpFillProfile") as! RegisterFillProfileViewController
        
        self.view.endEditing(true)
        self.navigationController?.pushViewController(signUpRegisterHintVC, animated: true)
        
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
