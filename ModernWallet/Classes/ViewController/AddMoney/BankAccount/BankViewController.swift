//
//  BankViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 6/28/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import RxSwift
import RxCocoa

class BankViewController: UIViewController {
    
    @IBOutlet weak var bicLabel: UILabel!
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var purposeOfPaymentLabel: UILabel!
    @IBOutlet weak var bankAddressLabel: UILabel!
    @IBOutlet weak var companyAddressLabel: UILabel!
    
    @IBOutlet weak var bicLbl: UILabel!
    @IBOutlet weak var accountNumberLbl: UILabel!
    @IBOutlet weak var accountNameLbl: UILabel!
    @IBOutlet weak var purposeOfPaymentLbl: UILabel!
    @IBOutlet weak var bankAddressLbl: UILabel!
    @IBOutlet weak var companyAddressLbl: UILabel!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    lazy var swiftCredentialsViewModel: SwiftCredentialsViewModel = {
        return SwiftCredentialsViewModel()
    }()
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.clear
        
        applyTranslations()
        
        swiftCredentialsViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        imageHeight.constant =  Display.height
    }
    
    func applyTranslations() {
        bicLbl.text = Localize("addMoney.newDesign.bankaccount.bic")
        accountNumberLbl.text = Localize("addMoney.newDesign.bankaccount.accountNumber")
        accountNameLbl.text = Localize("addMoney.newDesign.bankaccount.accountName")
        bankAddressLbl.text = Localize("addMoney.newDesign.bankaccount.bankAddress")
        purposeOfPaymentLbl.text = Localize("addMoney.newDesign.bankaccount.purpose")
        companyAddressLbl.text = Localize("addMoney.newDesign.bankaccount.companyAddress")
        
        emailButton.setTitle(Localize("addMoney.newDesign.bankaccount.emailMe"), for: UIControlState.normal)
        nextButton.setTitle(Localize("addMoney.newDesign.bankaccount.next"), for: UIControlState.normal)
    }

    
    @IBAction func nextAction(_ sender: UIButton) {
        
//        let parentVC = self.parent as! LWAddMoneyViewController
//        parentVC.nextAction(sender)
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

fileprivate extension SwiftCredentialsViewModel {
    func bind(toViewController vc: BankViewController) -> [Disposable] {
        return [
            bic.drive(vc.bicLabel.rx.text),
            accountNumber.drive(vc.accountNumberLabel.rx.text),
            accountName.drive(vc.accountNameLabel.rx.text),
            purposeOfPayment.drive(vc.purposeOfPaymentLabel.rx.text),
            bankAddress.drive(vc.bankAddressLabel.rx.text),
            companyAddress.drive(vc.companyAddressLabel.rx.text),
            loadingViewModel.isLoading.bind(to: vc.rx.loading),
            errors.drive(vc.rx.error)
        ]
    }
}
