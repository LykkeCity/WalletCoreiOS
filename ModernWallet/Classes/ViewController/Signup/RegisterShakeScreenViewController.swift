//
//  RegisterShakeScreenViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 9/12/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import RxCocoa
import RxSwift

class RegisterShakeScreenViewController: UIViewController {

    var shakeCount : Int = 0
    var isShakingNow : Bool = false
    
    @IBOutlet weak var shakesLabel: UILabel!
    
    var triggerButton: UIButton = UIButton(type: UIButtonType.custom)
    
    lazy var viewModel : ClientKeysViewModel={
        return ClientKeysViewModel(submit: self.triggerButton.rx.tap.asObservable() )
    }()
    

    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.applicationSupportsShakeToEdit = true
        shakeCount=0
        isShakingNow = false
        
        
        // Do any additional setup after loading the view.
        
        
        viewModel.loading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
        viewModel.result.asObservable()
            .filterError()
            .subscribe(onNext: { [weak self] errorData in
                guard let `self` = self else{return}
                self.show(error: errorData)
                self.shakeCount=0
                self.shakesLabel.text = String(self.shakeCount)
                
            })
            .disposed(by: disposeBag)
        
        viewModel.result.asObservable()
            .filterSuccess()
            .subscribe(onNext: {[weak self] pack in
                
                //gonext
                
                self?.dismisVC()
                
                //print("Success registration")
                //self.dismiss(animated: true) {
                //    UserDefaults.standard.set("true", forKey: "loggedIn")
                //    print("user is logged in")
               // }
                
            })
            .disposed(by: disposeBag)
        
    }
    
    func dismisVC() {
        UserDefaults.standard.set("true", forKey: "loggedIn")
        dismiss(animated: true) {
            NotificationCenter.default.post(name: .loggedIn, object: nil)
            print("Current screen is down")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if (motion == UIEventSubtype.motionShake)
        {
            shakeCount += 1
            shakesLabel.text = String(shakeCount)
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if (motion == UIEventSubtype.motionShake)
        {
            if(shakeCount == 3)
            {
                self.createKeys()
                
            }
        }
    }
    
    func createKeys(){
        
        if(LWPrivateKeyManager.shared().isPrivateKeyLykkeEmpty())
        {
            
            LWPrivateKeyManager.shared().savePrivateKeyLykke(fromSeedWords: LWPrivateKeyManager.generateSeedWords12())
            viewModel.pubKey.value = LWPrivateKeyManager.shared().publicKeyLykke
            viewModel.encodedPrivateKey.value = LWPrivateKeyManager.shared().encryptedKeyLykke
            self.triggerButton.sendActions(for: .touchUpInside)
            /*
             [[LWPrivateKeyManager shared] savePrivateKeyLykkeFromSeedWords:[LWPrivateKeyManager generateSeedWords12]];
             [self setLoading:YES];
             [[LWAuthManager instance] requestSaveClientKeysWithPubKey:[LWPrivateKeyManager shared].publicKeyLykke encodedPrivateKey:[LWPrivateKeyManager shared].encryptedKeyLykke];
             */
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
