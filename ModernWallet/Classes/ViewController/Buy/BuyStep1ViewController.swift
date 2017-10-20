//
//  BuyStep1ViewController.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import WalletCore

class BuyStep1ViewController: UIViewController {
    
    // MARK:- Views
    @IBOutlet weak var allCurrenciesButton: UIButton!
    @IBOutlet weak var allCryptoCurrenciesLabel: UILabel!
    @IBOutlet weak var allCryptoCurrenciesImage: UIImageView!
    @IBOutlet weak var fiatCurrenciesImage: UIImageView!
    @IBOutlet weak var fiatCurrenciesButton: UIButton!
    @IBOutlet weak var fiatCurrenciesLabel: UILabel!
    @IBOutlet weak var currenciesTableView: UITableView!
    @IBOutlet weak var cryptoCurrenciesButton: UIButton!
    @IBOutlet weak var cryptoCurrenciesImg: UIImageView!
    @IBOutlet weak var cryptoCurrenciesLabel: UILabel!
    
    
    // MARK:- Properties
    fileprivate let disposeBag = DisposeBag()
    fileprivate let filter = Variable<BuyStep1ViewModel.CurrencyType?>(nil)
    fileprivate lazy var viewModel:BuyStep1ViewModel = {
        return BuyStep1ViewModel(
            filter: self.filter.asObservable().filterNil(),
            dependency: (
                authManager: LWRxAuthManager.instance,
                currencyExchanger: CurrencyExchanger()
            )
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currenciesTableView.backgroundColor = UIColor.clear
        
        currenciesTableView.register(UINib(nibName: "PortfolioCurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: "PortfolioCurrencyTableViewCell")
        
        currenciesTableView.rx
            .modelSelected(BuyStep1CellViewModel.self)
            .map{$0.model}
            .subscribe(onNext: {[weak self] model in
                let buyStoryBoard = UIStoryboard.init(name: "Buy", bundle: nil)
                guard let buyViewControllerStep2 = buyStoryBoard.instantiateViewController(withIdentifier: "BuyStep2") as? BuyStep2ViewController else {return}
                buyViewControllerStep2.assetPairModel = model
                
                guard let buyViewController = self?.navigationController?.parent as? BuyViewController else {
                    self?.navigationController?.pushViewController(buyViewControllerStep2, animated: true)
                    return
                }
                
                buyViewController.assetPairModel = model
                buyViewController.graphSetUp()
                self?.navigationController?.pushViewController(buyViewControllerStep2, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.cellViewModels.asObservable()
            .bind(to: currenciesTableView.rx.items(cellIdentifier: "PortfolioCurrencyTableViewCell", cellType: PortfolioCurrencyTableViewCell.self)) { (row, element, cell) in
                cell.bind(toAssetPair: element)
            }
            .disposed(by: disposeBag)
        
        viewModel.loading.isLoading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
        bindButtonsToFilter()
        bindFilterButtonsHighlighted()
        bindSelectCurrencyLabel()
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


// MARK: - Rx Bindings
fileprivate extension BuyStep1ViewController {
    func bindFilterButtonsHighlighted() {
        viewModel.currencyFilter
            .map{$0.isFiat()}
            .drive(fiatCurrenciesImage.rx.isHighlighted)
            .disposed(by: disposeBag)
        
        viewModel.currencyFilter
            .map{$0.isCrypto()}
            .drive(cryptoCurrenciesImg.rx.isHighlighted)
            .disposed(by: disposeBag)
        
        viewModel.currencyFilter
            .map{$0.isAll()}
            .drive(allCryptoCurrenciesImage.rx.isHighlighted)
            .disposed(by: disposeBag)
    }
    
    func bindButtonsToFilter() {
        let fiatObservable = fiatCurrenciesButton.rx.tap.asObservable().map{BuyStep1ViewModel.CurrencyType.fiat}
        let cryptoObservable = cryptoCurrenciesButton.rx.tap.asObservable().map{BuyStep1ViewModel.CurrencyType.crypto}
        let allObservable = allCurrenciesButton.rx.tap.asObservable().map{BuyStep1ViewModel.CurrencyType.all}
        
        Observable
            .of(fiatObservable, cryptoObservable, allObservable)
            .merge()
            .bind(to: filter)
            .disposed(by: disposeBag)
    }
    
    func bindSelectCurrencyLabel() {
        guard let buyViewController = parent?.parent as? BuyViewController else {return}
        
        viewModel.selectCurrencyLabel
            .drive(buyViewController.selectCurrencyLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

fileprivate extension PortfolioCurrencyTableViewCell {
    func bind(toAssetPair assetPair: BuyStep1CellViewModel) {
        self.disposeBag = DisposeBag()
        
        assetPair.assetPairCodes
            .drive(cryptoNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        assetPair.capitalization
            .drive(percentLabel.rx.text)
            .disposed(by: disposeBag)
        
        assetPair.change
            .drive(valueLabel.rx.text)
            .disposed(by: disposeBag)

        assetPair.price
            .drive(cryptoValueLabel.rx.text)
            .disposed(by: disposeBag)
        
        assetPair.iconUrl
            .drive(iconImageView.rx.afImage)
            .disposed(by: disposeBag)
    }
}
