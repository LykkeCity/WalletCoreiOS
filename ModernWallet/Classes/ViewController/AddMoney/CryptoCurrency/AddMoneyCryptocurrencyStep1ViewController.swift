//
//  AddMoneyCryptocurrencyStep1ViewController.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 6/30/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import WalletCore
import AlamofireImage

class AddMoneyCryptocurrencyStep1ViewController: UIViewController {
    
    @IBOutlet weak var currenciesTableView: UITableView!
    
    let disposeBag = DisposeBag()

    fileprivate lazy var cryptoCurrenciesViewModel: CryptoCurrenciesViewModel = {
        return CryptoCurrenciesViewModel()
    }()

    fileprivate lazy var loadingViewModel: LoadingViewModel = {
        return LoadingViewModel([
            self.cryptoCurrenciesViewModel.loadingViewModel.isLoading
            ])
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currenciesTableView.backgroundColor = UIColor.clear
        
        currenciesTableView.register(UINib(nibName: "AddMoneyCryptoCurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: "AddMoneyCryptoCurrencyTableViewCell")
        loadingViewModel.isLoading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
        cryptoCurrenciesViewModel.walletsData
            .bind(to: currenciesTableView.rx.items(cellIdentifier: "AddMoneyCryptoCurrencyTableViewCell",
                                                                    cellType: AddMoneyCryptoCurrencyTableViewCell.self)) { (row, element, cell) in
                                                                        cell.bind(toCurrency: AddMoneyCryptoCurrencyCellViewModel(element))
                            }
                            .disposed(by: disposeBag)
        
        
        currenciesTableView.rx.itemSelected.asObservable()
            .subscribe(onNext: {[weak self] indexPath in
                self?.performSegue(withIdentifier: "cc2Segue", sender: self)
            })
            .disposed(by: disposeBag)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


