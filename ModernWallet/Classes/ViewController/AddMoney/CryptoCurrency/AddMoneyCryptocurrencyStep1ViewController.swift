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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currenciesTableView.backgroundColor = UIColor.clear

        currenciesTableView.register(UINib(nibName: "AddMoneyCryptoCurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: "AddMoneyCryptoCurrencyTableViewCell")
        
        LWRxAuthManager.instance.lykkeWallets.request()
            .filterSuccess()
            .map{$0.lykkeData.wallets.filter {
                            return ($0 as! LWSpotWallet).asset.blockchainDeposit
                }.map({ (wallet) -> Variable<LWAddMoneyCryptoCurrencyModel> in
                    let w: LWSpotWallet = wallet as! LWSpotWallet
                    return Variable(LWAddMoneyCryptoCurrencyModel(name:w.name,
                                                                address:w.asset.blockchainDepositAddress,
                                                                imageUrl:URL(string: w.asset.iconUrlString)))
                })
                
            }.bind(to: currenciesTableView.rx.items(cellIdentifier: "AddMoneyCryptoCurrencyTableViewCell",
                                                    cellType: AddMoneyCryptoCurrencyTableViewCell.self)) { (row, element, cell) in
                                                        cell.bind(toCurrency: AddMoneyCryptoCurrencyCellViewModel(element))
            }
            .disposed(by: disposeBag)



//
//        currenciesTableView.rx.itemSelected.asObservable()
//            .subscribe(onNext: {[weak self] indexPath in
//                self?.performSegue(withIdentifier: "cc2Segue", sender: self)
//            })
//            .disposed(by: disposeBag)
        
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
