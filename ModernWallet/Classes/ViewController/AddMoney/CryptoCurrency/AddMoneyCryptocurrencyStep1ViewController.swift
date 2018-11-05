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
    
    fileprivate lazy var blockchainAddressViewModel: BlockchainAddressViewModel = {
        return BlockchainAddressViewModel(alertPresenter: self)
    }()
    
    fileprivate lazy var loadingViewModel: LoadingViewModel = {
        return LoadingViewModel([
            self.cryptoCurrenciesViewModel.isLoading
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
            .map { $0.value.asset }
            .do(onNext: { [weak self] _ in
                guard let strongSelf = self,
                    let selectedRow = strongSelf.currenciesTableView.indexPathForSelectedRow else { return }
                strongSelf.currenciesTableView.deselectRow(at: selectedRow, animated: false) })
            .bind(to: blockchainAddressViewModel.asset)
            .disposed(by: disposeBag)
        
        blockchainAddressViewModel
            .bind(to: self)
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
            
            let m: LWAssetModel = sender as! LWAssetModel
            let model = LWPrivateWalletModel()
            model.name = m.name
            model.address = m.blockchainDepositAddress
            model.iconURL = m.iconUrl?.absoluteString
            
            vc.wallet = Variable(model)
        }
    }
}

extension BlockchainAddressViewModel {
    func bind (to vc: AddMoneyCryptocurrencyStep1ViewController) -> [Disposable] {
        return [
            assetModel
                .subscribe(onNext: { [weak vc] model in
                    vc?.performSegue(withIdentifier: "cc2Segue", sender: model)
                }),
            blockchainAddressReceived
                .map { Localize("blockchainAddress.reveived") }
                .drive(vc.rx.messageBottom),
            errors
                .bind(to: vc.rx.error),
            loadingViewModel.isLoading
                .asDriver(onErrorJustReturn: false)
                .drive(vc.rx.loading)
        ]
    }
}


