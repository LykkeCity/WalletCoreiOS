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
    
    @IBOutlet weak var filterDescriptionView: UIStackView!
    @IBOutlet weak var filterDescriptionLabel: UILabel!
    @IBOutlet weak var filterDescriptionClearButton: UIButton!
    @IBOutlet weak var headerHeight: NSLayoutConstraint!

    private var filterViewController: TransactionPickDateRangeViewController?
    
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
    
    var asset: Observable<Asset>!
    var assetModel: Asset!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        asset
            .bind{ [weak self] in self?.assetModel = $0 }
            .disposed(by: disposeBag)
        
        transactionsTable.contentInset = UIEdgeInsetsMake(0, 0, 44, 0)

        transactionsTable.register(UINib(nibName: "AssetInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "AssetInfoTableViewCell")
        
        transactionsViewModel.transactionsAsCsv = self.messageButton.rx.tap
            .asObservable()
            .mapToCSVURL(transactions: transactionsViewModel
                                        .transactions
                                        .asObservable()
                                        .filter(byAsset: asset))

        
        transactionsViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)

        transactionsViewModel.loading.isLoading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)

        assetBalanceViewModel
            .bind(toAsset: assetAmount, baseAsset: baseAssetAmount)
            .disposed(by: disposeBag)

        asset.mapToCryptoName()
            .asDriver(onErrorJustReturn: "")
            .drive(rx.title)
            .disposed(by: disposeBag)
        
        asset
            .map{$0.wallet?.asset.blockchainWithdraw ?? false}
            .asDriver(onErrorJustReturn: false)
            .drive(sendButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        assetBalanceViewModel.blockchainAddress.asDriver()
            .map{ $0.isNotEmpty }
            .drive(receiveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        assetAmount.configure(fontSize: 30)
        baseAssetAmount.configure(fontSize: 12)

        // Table header and filter content bindings
        transactionsViewModel.filterViewModel.filterDescription
            .drive(filterDescriptionLabel.rx.attributedText)
            .disposed(by: disposeBag)
        
        transactionsViewModel.filterViewModel.filterDatePair.asObservable()
            .map { return $0.start == nil && $0.end == nil }
            .startWith(true)
            .asDriver(onErrorJustReturn: true)
            .drive(filterDescriptionView.rx.isHidden)
            .disposed(by: disposeBag)

        filterDescriptionClearButton.rx.tap.asObservable()
            .throttle(1.0, scheduler: MainScheduler.instance)
            .map({ return (start: nil, end: nil) })
            .bind(to: transactionsViewModel.filterViewModel.filterDatePair)
            .disposed(by: disposeBag)
        
        transactionsViewModel.isDownloadButtonEnabled
            .drive(messageButton.rx.isEnabled)
            .disposed(by: disposeBag)
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
            buyVC.tradeAssetIdentifier = assetModel.cryptoCurrency.identity
            buyVC.currencyExchanger = currencyExchanger
        case "SellAsset":
            guard let sellVC = segue.destination as? BuyOptimizedViewController else { return }
            sellVC.tradeType = .sell
            sellVC.tradeAssetIdentifier = assetModel.cryptoCurrency.identity
            sellVC.currencyExchanger = currencyExchanger
        case "ReceiveAddress":
            guard let receiveVC = segue.destination as? ReceiveWalletViewController else { return }
            receiveVC.asset = Variable(assetModel)
            receiveVC.address = assetBalanceViewModel.blockchainAddress.value
        case "SendAsset":
            guard let sendVC = segue.destination as? SendToWalletViewController else { return }
            sendVC.asset = Variable(assetModel)
        case "ShowFilterPopover":
            guard let filterNavigationController = segue.destination as? UINavigationController,
                let filterViewController = filterNavigationController.topViewController as? TransactionPickDateRangeViewController else { return }
            
            filterNavigationController.modalPresentationStyle = UIModalPresentationStyle.popover
            filterNavigationController.preferredContentSize = CGSize(width: transactionsTable.bounds.width, height: 280)

            if let filterPopover = filterNavigationController.popoverPresentationController {
                // Calculate the offset for the popover depending on the screen size
                let popoverOffset: CGFloat = UIScreen.isSmallScreen ? -16 : 16

                filterPopover.backgroundColor = Colors.darkGreen
                filterPopover.permittedArrowDirections = UIScreen.isSmallScreen ? .down : .up
                filterPopover.sourceView = self.filterButton
                filterPopover.delegate = self
                filterPopover.sourceRect = CGRect(x: self.filterButton.bounds.midX, y: self.filterButton.bounds.midY + popoverOffset, width: 0,height: 0)
            }
            
            filterViewController.filterViewModel = transactionsViewModel.filterViewModel
            
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
                .filter(byAsset: vc.asset)
                .bind(
                    to: vc.transactionsTable.rx.items(cellIdentifier: "AssetInfoTableViewCell",
                                                   cellType: AssetInfoTableViewCell.self)
                ){ (row, element, cell) in
                    cell.bind(toTransaction: element)
                },
            loading.isLoading
                .bind(to: vc.rx.loading),
            transactionsAsCsv
                .asObservable()
                .filterSuccess()
                .bind(onNext: {[weak vc] path in vc?.creatCSV(path)}),
            
            errors.drive(vc.rx.error)
        ]
    }
}
extension AssetDetailViewController: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
            return .none
    }
}

extension ObservableType where Self.E == [TransactionViewModel] {
    func filter(byAsset asset: Observable<Asset>) -> Observable<[TransactionViewModel]> {
        return
            withLatestFrom(asset) {(transactions: $0, asset: $1)}
            .map{ data in
                data.transactions.filter{transaction in
                    transaction.transaction.asset == data.asset.wallet?.asset.identity
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
