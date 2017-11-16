//
//  AssetDetailViewController.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 15.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import WalletCore

class AssetDetailViewController: UIViewController {

    @IBOutlet weak var backgroundHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var assetName: UILabel!
    @IBOutlet weak var baseAssetAmount: AssetAmountView!
    @IBOutlet weak var assetAmount: AssetAmountView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var transactionsTap: UITapGestureRecognizer!
    
    @IBOutlet weak var transactionsTable: UITableView!
    @IBOutlet weak var messageButton: UIButton!
    
    fileprivate lazy var assetBalanceViewModel: AssetBalanceViewModel = {
        return AssetBalanceViewModel(asset: self.asset.asObservable())
    }()
    
    fileprivate lazy var transactionsViewModel: TransactionsViewModel = {
        return TransactionsViewModel(
            downloadCsv: Observable.empty(),
            currencyExchanger: CurrencyExchanger()
        )
    } ()
    
    private let disposeBag = DisposeBag()
    
    var asset: Variable<Asset>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundHeightConstraint.constant = Display.height
        
        transactionsTable.register(UINib(nibName: "PortfolioCurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: "PortfolioCurrencyTableViewCell")
        
        transactionsViewModel.transactions.asObservable()
            .filter(byAsset: asset.value)
            .bind(
                to: transactionsTable.rx.items(cellIdentifier: "PortfolioCurrencyTableViewCell",
                                                   cellType: PortfolioCurrencyTableViewCell.self)
            ){ (row, element, cell) in
                cell.bind(toTransaction: element)
            }
            .disposed(by: disposeBag)
        
        transactionsViewModel.loading.isLoading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
        assetBalanceViewModel
            .bind(toAsset: assetAmount, baseAsset: baseAssetAmount)
            .disposed(by: disposeBag)
        
        asset
            .asObservable()
            .mapToCryptoName()
            .asDriver(onErrorJustReturn: "")
            .drive(assetName.rx.text)
            .disposed(by: disposeBag)
        
        assetAmount.configure(fontSize: 30.1)
        baseAssetAmount.configure(fontSize: 11.7)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
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

extension ObservableType where Self.E == [TransactionViewModel] {
    func filter(byAsset asset: Asset) -> Observable<[TransactionViewModel]> {
        return map{ transactions in
            transactions.filter{transaction in
                transaction.transaction.asset == asset.wallet?.asset.identity
            }
        }
    }
}

extension AssetBalanceViewModel {
    func bind(toAsset asset: AssetAmountView, baseAsset: AssetAmountView) -> [Disposable] {
        return [
            assetBalance.drive(asset.rx.amount),
            assetBalanceInBase.drive(baseAsset.rx.amount),
            assetCode.drive(asset.rx.code),
            baseAssetCode.drive(baseAsset.rx.code)
        ]
    }
}

fileprivate extension AssetAmountView {
    func configure(fontSize: CGFloat) {
        codeFont = UIFont(name: "Geomanist-Light", size: fontSize)
        amountFont = UIFont(name: "Geomanist-Light", size: fontSize)
    }
}
