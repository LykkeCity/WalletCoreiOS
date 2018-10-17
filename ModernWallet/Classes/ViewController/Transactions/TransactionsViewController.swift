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
    
    var searchContainer: UISearchContainerViewController? {
        willSet {
            if newValue == nil {
                UIView.animate(
                    withDuration: 0.3,
                    animations: { self.searchContainer?.searchController.searchBar.alpha = 0.0 },
                    completion: { _ in self.searchContainer?.searchController.searchBar.removeFromSuperview() }
                )
                transactionsController?.findTransactionImg.image = #imageLiteral(resourceName: "searchIcon")
            }
            else {
                transactionsController?.findTransactionImg.image = #imageLiteral(resourceName: "searchIconSelected")
            }
        }
        
        didSet {
            guard let container = searchContainer else { return }
            container.searchController.delegate = self
            self.view.addSubview(container.searchController.searchBar)
            container.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    var transactionsController: TransactionsStep1ViewController? {
        return childViewControllers.first{ $0 is TransactionsStep1ViewController } as? TransactionsStep1ViewController
    }
    
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
        
        
        transactionsController?.findTransactionBtn.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.searchContainer = TransactionsStep1ViewController.factorySearchContainer(
                    withViewModel: self?.transactionsController?.transactionsViewModel
                )
            })
            .disposed(by: disposeBag)
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.searchContainer?.searchController.isActive = false
        
    }
}

extension TransactionsViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        // nulify searchContainer so that will be removed from the superview
        searchContainer = nil
    }
}
