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
    
    
    var assets = Variable<[Variable<Asset>]>([])
    fileprivate lazy var totalBalanceViewModel: TotalBalanceViewModel = {
        return TotalBalanceViewModel(refresh: ReloadTrigger.instance.trigger(interval: 10))
    }()
    
    fileprivate lazy var walletsViewModel: WalletsViewModel = {
        return WalletsViewModel(
            refreshWallets: Observable.just(Void()),
            mainInfo: self.totalBalanceViewModel.observables.mainInfo.filterSuccess()
        )
    }()
    
    fileprivate lazy var loadingViewModel: LoadingViewModel = {
        return LoadingViewModel([
            self.totalBalanceViewModel.loading.isLoading,
            self.walletsViewModel.loadingViewModel.isLoading
            ])
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        currenciesTableView.backgroundColor = UIColor.clear
        
        currenciesTableView.register(UINib(nibName: "AddMoneyCryptoCurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: "AddMoneyCryptoCurrencyTableViewCell")
        loadingViewModel.isLoading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
        //        walletsViewModel.wallets
        //            .asObservable()
        //            .map{$0
        //                .filter{($0.value.wallet?.asset.blockchainDeposit)!}
        //                .map{
        //                    return Variable(LWAddMoneyCryptoCurrencyModel(name:($0.value.wallet?.asset.name)!,
        //                                                                  address:$0.value.wallet?.asset.blockchainDepositAddress,
        //                                                                  imageUrl:$0.value.wallet?.asset.iconUrl))
        //                }
        //            }.bind(to: currenciesTableView.rx.items(cellIdentifier: "AddMoneyCryptoCurrencyTableViewCell",
        //                                              cellType: AddMoneyCryptoCurrencyTableViewCell.self)) { (row, element, cell) in
        //                                                cell.bind(toCurrency: AddMoneyCryptoCurrencyCellViewModel(element))
        //            }
        //            .disposed(by: disposeBag)
        //
        
        
        let lykkeWallets = LWRxAuthManager.instance.lykkeWallets.request()
        
        lykkeWallets.filterSuccess()
            .map{$0.lykkeData.wallets.filter {
                return ($0 as! LWSpotWallet).asset.blockchainDeposit && (($0 as! LWSpotWallet).asset.blockchainDepositAddress != nil)
                }.map({ (wallet) -> Variable<LWAddMoneyCryptoCurrencyModel> in
                    let w: LWSpotWallet = wallet as! LWSpotWallet
                    let model = LWAddMoneyCryptoCurrencyModel(name:w.name,
                                                              address:w.asset.blockchainDepositAddress,
                                                              imageUrl:w.asset.iconUrl)
                    return Variable(model)
                })
                
            }.bind(to: currenciesTableView.rx.items(cellIdentifier: "AddMoneyCryptoCurrencyTableViewCell",
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
        
        
        bindViewModels()
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
            model.address = m.value.address
            model.iconURL = m.value.imgUrl?.absoluteString
            
            vc.wallet = Variable(model)
        }
    }
}

fileprivate extension TotalBalanceViewModel {
    func bind(toVieController viewController: AddMoneyCryptocurrencyStep1ViewController) -> [Disposable] {
        return [
            observables.baseAsset.filterSuccess().subscribe(onNext: {asset in LWCache.instance().baseAssetId = asset.identity})
        ]
    }
}
extension AddMoneyCryptocurrencyStep1ViewController {
    func bindViewModels() {
        
        totalBalanceViewModel
            .bind(toVieController: self)
            .disposed(by: disposeBag)
        
        walletsViewModel.wallets
            .bind(to: assets)
            .disposed(by: disposeBag)
    }
}

