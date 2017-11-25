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

class AddMoneyCryptocurrencyStep1ViewController: UIViewController {

    @IBOutlet weak var currenciesTableView: UITableView!
    
    let disposeBag = DisposeBag()
    let currencies = FakeData.cryptoCyrrency
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currenciesTableView.backgroundColor = UIColor.clear

        currenciesTableView.register(UINib(nibName: "PortfolioCurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: "PortfolioCurrencyTableViewCell")

        
        currenciesTableView.rx.itemSelected.asObservable()
            .subscribe(onNext: {[weak self] indexPath in
                self?.performSegue(withIdentifier: "cc2Segue", sender: self)
            })
            .disposed(by: disposeBag)
        
        currencies.asObservable()
            .bind(to: currenciesTableView.rx.items(cellIdentifier: "PortfolioCurrencyTableViewCell", cellType: PortfolioCurrencyTableViewCell.self)) { (row, element, cell) in
                cell.bind(toCurrency: CryptoCurrencyCellViewModel(element))
            }
            .disposed(by: disposeBag)
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
