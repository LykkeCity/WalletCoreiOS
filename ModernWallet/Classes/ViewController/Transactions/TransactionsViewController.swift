//
//  TransactionsViewController.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 7/11/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import KYDrawerController
import WalletCore

class TransactionsViewController: UIViewController {
    @IBOutlet weak var transactionLabel: UILabel!
    @IBOutlet weak var totalBalanceContainer: UIView!
    @IBOutlet weak var showHideGraphButton: UIButton!
    @IBOutlet weak var graphViewContainer: UIView!
    
    let disposeBag = DisposeBag()
    
    let isGraphHidden = Variable(true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        transactionLabel.text = Localize("transaction.newDesign.transactionTitle")

        isGraphHidden.asDriver()
            .map{!$0}
            .drive(totalBalanceContainer.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        isGraphHidden.asDriver()
            .drive(graphViewContainer.rx.isHidden)
            .disposed(by: disposeBag)
        
        showHideGraphButton.rx.tap
            .map{[weak self] in self?.isGraphHidden.value}
            .filterNil()
            .map{!$0}
            .bind(to: isGraphHidden)
            .disposed(by: disposeBag)
        // Do any additional setup after loading the view.
        
    }

    @IBAction func onBackTap(_ sender: UIButton) {
        if let drawerController = self.parent as? KYDrawerController {
            let mainStory = UIStoryboard.init(name: "Main", bundle: nil)
            drawerController.mainViewController = mainStory.instantiateViewController(withIdentifier: "PortfolioContainer")
        }
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
