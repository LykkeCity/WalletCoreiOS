//
//  StartViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 6/28/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import RxSwift

class StartViewController: UIViewController {
    
    @IBOutlet weak var bankAccountLabel: UILabel!
    @IBOutlet weak var creditCardLabel: UILabel!
    @IBOutlet weak var receiveCryptoLabel: UILabel!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    private let disposeBag = DisposeBag()
    
    private let asset = Variable<ApiResult<LWAssetModel>?>(nil)
    private lazy var kycNeededViewModel: KycNeededViewModel = {
        return KycNeededViewModel(forAsset: self.asset.asObservable().filterNil())
    }()
    
    func presentPendingViewController() {
        let pendingViewController = UIStoryboard(name: "KYC", bundle: nil).instantiateViewController(withIdentifier: "kycPendingVC")
        navigationController?.present(pendingViewController, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default
            .addObserver(self, selector: #selector(StartViewController.presentPendingViewController), name: .kycDocumentsUploadedOrApproved, object: nil)
        
        self.view.backgroundColor = UIColor.clear
        bankAccountLabel.text = Localize("addMoney.newDesign.bankAccount")
        creditCardLabel.text = Localize("addMoney.newDesign.creditCard")
        receiveCryptoLabel.text = Localize("addMoney.newDesign.receiveCrypto")
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        imageHeight.constant =  Display.height
        
        kycNeededViewModel.loadingViewModel.isLoading
            .bind(to: self.rx.loading)
            .disposed(by: disposeBag)
        
        kycNeededViewModel.needToFillData
            .map{UIStoryboard(name: "KYC", bundle: nil).instantiateViewController(withIdentifier: "kycTabNVC")}
            .subscribe(onNext: {[weak self] controller in
                self?.navigationController?.present(controller, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        kycNeededViewModel.ok
            .map{[weak self] in self?.storyboard?.instantiateViewController(withIdentifier: "addMoneyCCstep1VC")}
            .filterNil()
            .subscribe(onNext: {[weak self] controller in
                self?.navigationController?.pushViewController(controller, animated: true)
            })
            .disposed(by: disposeBag)
        
        
        kycNeededViewModel.pending
            .map{UIStoryboard(name: "KYC", bundle: nil).instantiateViewController(withIdentifier: "kycPendingVC")}
            .subscribe(onNext: {[weak self] controller in
                self?.navigationController?.present(controller, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }

    
    @IBAction func bankAccountAction(_ sender: UIButton) {
        
//        let parentVC = self.parent as! LWAddMoneyViewController
//        parentVC.bankAccountAction(sender)
    }
    
    @IBAction func creditCardAction(_ sender: UIButton) {
        LWRxAuthManager.instance.baseAsset.request()
            .bind(to: asset)
            .disposed(by: disposeBag)
    }
    
    @IBAction func cryptoCurrencyAction(_ sender: UIButton) {
//        let parentVC = self.parent as! LWAddMoneyViewController
//        parentVC.cryptoCurrencyAction(sender)
        
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
