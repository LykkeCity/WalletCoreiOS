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

    @IBOutlet weak var baseAssetAmount: AssetAmountView!
    @IBOutlet weak var assetAmount: AssetAmountView!
    @IBOutlet weak var receiveButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var transactionsTap: UITapGestureRecognizer!
    
    @IBOutlet weak var sendButton: IconOverTextButton!
    @IBOutlet weak var transactionsTable: UITableView!
    @IBOutlet weak var messageButton: UIButton!
    
    fileprivate lazy var assetBalanceViewModel: AssetBalanceViewModel = {
        return AssetBalanceViewModel(asset: self.asset.asObservable())
    }()
    
    fileprivate lazy var currencyExchanger: CurrencyExchanger = {
        return CurrencyExchanger()
    }()
    
    fileprivate lazy var transactionsViewModel: TransactionsViewModel = {
        return TransactionsViewModel(
            downloadCsv: self.messageButton.rx.tap.asObservable(),
            dependency: (
                currencyExcancher: self.currencyExchanger,
                authManager: LWRxAuthManager.instance,
                formatter: TransactionFormatter.instance
            )
        )
    } ()
    
    private let disposeBag = DisposeBag()
    
    var asset: Variable<Asset>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transactionsTable.register(UINib(nibName: "PortfolioCurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: "PortfolioCurrencyTableViewCell")
        
        transactionsViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        assetBalanceViewModel
            .bind(toAsset: assetAmount, baseAsset: baseAssetAmount)
            .disposed(by: disposeBag)

        asset.asObservable()
            .mapToCryptoName()
            .asDriver(onErrorJustReturn: "")
            .drive(rx.title)
            .disposed(by: disposeBag)
        
        asset.asDriver()
            .map{$0.wallet?.asset.blockchainWithdraw ?? false}
            .drive(sendButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        assetBalanceViewModel.blockchainAddress.asDriver()
            .map{ $0.isNotEmpty }
            .drive(receiveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        assetAmount.configure(fontSize: 30)
        baseAssetAmount.configure(fontSize: 12)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = segue.identifier else {
            return
        }
        switch segueIdentifier {
        case "BuyAsset":
            guard let buyVC = segue.destination as? BuyOptimizedViewController else { return }
            buyVC.tradeType = .buy
            buyVC.tradeAssetIdentifier = asset.value.cryptoCurrency.identity
            buyVC.currencyExchanger = currencyExchanger
        case "SellAsset":
            guard let sellVC = segue.destination as? BuyOptimizedViewController else { return }
            sellVC.tradeType = .sell
            sellVC.tradeAssetIdentifier = asset.value.cryptoCurrency.identity
            sellVC.currencyExchanger = currencyExchanger
        case "ReceiveAddress":
            guard let receiveVC = segue.destination as? ReceiveWalletViewController else { return }
            receiveVC.asset = asset
            receiveVC.address = assetBalanceViewModel.blockchainAddress.value
        case "SendAsset":
            guard let sendVC = segue.destination as? SendToWalletViewController else { return }
            sendVC.asset = asset
        default:
            break
        }
    }

    func creatCSV(_ path: URL) -> Void {
        let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
}

fileprivate extension TransactionsViewModel {
    func bind(toViewController vc: AssetDetailViewController) -> [Disposable] {
        return [
            transactions.asObservable()
                .filter(byAsset: vc.asset.value)
                .bind(
                    to: vc.transactionsTable.rx.items(cellIdentifier: "PortfolioCurrencyTableViewCell",
                                                   cellType: PortfolioCurrencyTableViewCell.self)
                ){ (row, element, cell) in
                    cell.bind(toTransaction: element)
                },
            loading.isLoading
                .bind(to: vc.rx.loading),
            transactionsAsCsv
                .filterSuccess()
                .drive(onNext: {[weak vc] path in vc?.creatCSV(path)})
        ]
    }
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
