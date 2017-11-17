//
//  BankInfoViewControllerViewController.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 16.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class BankInfoViewController: UIViewController {

    @IBOutlet weak var backgroundHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    private lazy var currencyDepositViewModel: CurrencyDepositViewModel = {
        return CurrencyDepositViewModel(trigger: self.emailButton.rx.tap.asObservable())
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundHeightConstraint.constant = Display.height
        
        //get user's base asset and assign it to the view model
        LWRxAuthManager.instance.baseAsset.request()
            .filterSuccess()
            .map{ $0.identity ?? "" }
            .bind(to: currencyDepositViewModel.assetId)
            .disposed(by: disposeBag)
        
        currencyDepositViewModel.balanceChange.value = 100

        currencyDepositViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)

        // Do any additional setup after loading the view.
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

fileprivate extension CurrencyDepositViewModel {
    func bind(toViewController vc: BankInfoViewController) -> [Disposable] {
        return [
            loadingViewModel.isLoading.bind(to: vc.rx.loading),
            result.drive(onNext: { [weak vc] _ in vc?.performSegue(withIdentifier: "showWireBankEmailSent", sender: nil) }),
            errors.bind(to: vc.rx.error)
        ]
    }
}
