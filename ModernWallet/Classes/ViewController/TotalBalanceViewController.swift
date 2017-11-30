//
//  TotalBalanceViewController.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 7/20/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class TotalBalanceViewController: UIViewController {

    @IBOutlet weak var currencyCode: UILabel!
    @IBOutlet weak var totalBalanceAmaunt: UILabel!
    @IBOutlet weak var totalBalanceLabel: UILabel!
    
    private let viewModel = TotalBalanceViewModel(refresh: ReloadTrigger.instance.trigger(interval: 10))
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        
        viewModel.balance
            .drive(totalBalanceAmaunt.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.currencyName
            .drive(currencyCode.rx.text)
            .disposed(by: disposeBag)

// TODO: Move loading indicator in parent controller (this one where resides Total Balance view controller)
//        viewModel.loading.isLoading
//            .bind(to: rx.loading)
//            .disposed(by: disposeBag)
        
        totalBalanceLabel.text = Localize("totalbalance.newDesign.totalValue")
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
