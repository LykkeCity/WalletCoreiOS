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
        
        currenciesTableView.rx
            .modelSelected(Variable<LWAddMoneyCryptoCurrencyModel>.self)
            .subscribe(onNext: { [weak self] model in
                self?.performSegue(withIdentifier: "cc2Segue", sender: model)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cc2Segue" {
            guard let vc = segue.destination as? AddMoneyCryptocurrencyStep2ViewController else {
                return
            }
            let m: Variable<LWAddMoneyCryptoCurrencyModel> = sender as! Variable<LWAddMoneyCryptoCurrencyModel>
            let model = LWPrivateWalletModel()
            model.name = m.value.name
            model.address = m.value.address
            model.iconURL = m.value.imgUrl?.absoluteString
            
            vc.wallet = Variable(model)
        }
    }
}


