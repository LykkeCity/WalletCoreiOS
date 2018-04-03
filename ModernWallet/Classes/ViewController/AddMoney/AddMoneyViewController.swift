//
//  AddMoneyViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 6/19/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import KYDrawerController
import RxSwift
import RxCocoa
import WalletCore

class AddMoneyViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var pageIndicatorBtn1: UIButton!
    @IBOutlet weak var pageIndicatorBtn2: UIButton!
    @IBOutlet weak var pageIndicatorBtn3: UIButton!
    @IBOutlet weak var startView: UIView!
    @IBOutlet weak var addMoneyLabel: UILabel!
    @IBOutlet weak var pageIndicatorConstraint: NSLayoutConstraint!
    
    var navController: UINavigationController? {
        return (childViewControllers.first{$0 is UINavigationController}) as? UINavigationController
    }
    
    var pageIndicators: [UIButton] {
        return [pageIndicatorBtn1, pageIndicatorBtn2, pageIndicatorBtn3]
    }
    
    var moneyLabel: UILabel! {
        return addMoneyLabel
    }
    
    var bankAccountSel : Bool = false
    var ccSel : Bool = false
    var cryptoSel : Bool = false
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUserInterface()
        navController?.delegate = self
    }
    
    func setUserInterface() {
    
        pageIndicatorBtn1.isSelected = true
        pageIndicatorBtn2.isSelected = false
        pageIndicatorBtn3.isSelected = false
        
        pageIndicatorBtn1.isHidden = true
        pageIndicatorBtn2.isHidden = true
        pageIndicatorBtn3.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backAction(_ sender:UIButton) {
        navController?.popViewController(animated: true)
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

extension AddMoneyViewController: NavigationWizzardProtocol, UINavigationControllerDelegate {
    
    func getMaxIndicatorCount(_ navigationController: UINavigationController, willShow viewController: UIViewController) -> Int {
        return (navigationController.childViewControllers.filter{$0 is AddMoneyCCStep1ViewController}).isNotEmpty
            ? 3 : 2
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        manageBackButtonVisibility(navigationController, willShow: viewController)
        managePageIndicators(navigationController, willShow: viewController)
        manageAddMoneyLabel(navigationController, willShow: viewController)
    }
}

