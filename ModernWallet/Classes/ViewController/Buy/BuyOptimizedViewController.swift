//
//  BuyOptimizedViewController.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 10/5/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import RxSwift
import RxCocoa
import Toast

class BuyOptimizedViewController: UIViewController {
    
    //MARK:- IB Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var secondAssetList: BuyAssetListView!
    @IBOutlet weak var firstAssetList: BuyAssetListView!
    @IBOutlet weak var spreadAmount: UILabel!
    @IBOutlet weak var spreadPercent: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    //MARK:- Properties
    let assetModel = Variable<LWAssetModel?>(nil)
    
    var pinPassed = Variable(false)
    
    var confirmTrading = PublishSubject<Void>()
    
    let bid = Variable<Bool?>(nil)
    
    public var tradeType: TradeType!
    
    public var tradeAssetIdentifier: String?
    
    fileprivate let disposeBag = DisposeBag()
    
    //MARK:- View Models
    lazy var buyOptimizedViewModel: BuyOptimizedViewModel = {
        return BuyOptimizedViewModel(withTrigger: self.confirmTrading)
    }()
    
    lazy var payWithAssetListViewModel: PayWithAssetListViewModel = {
        return PayWithAssetListViewModel(buyAsset: self.buyOptimizedViewModel.buyAsset.asObservable().mapToAsset())
    }()
    
    lazy var buyWithAssetListViewModel: BuyWithAssetListViewModel = {
        return BuyWithAssetListViewModel(sellAsset: self.buyOptimizedViewModel.payWithWallet.asObservable().mapToAsset())
    }()
    
    lazy var tradingAssetsViewModel: TradingAssetsViewModel = {
        return TradingAssetsViewModel()
    }()
    
    var loadingViewModel: LoadingViewModel!
    
    lazy var offchainTradeViewModel: OffchainTradeViewModel = {
        return OffchainTradeViewModel(offchainService: OffchainService.instance)
    }()
    
    private let totalBalanceViewModel = TotalBalanceViewModel()
    
    //MARK:- Computed properties
    var walletListView: BuyAssetListView {
        return tradeType.isBuy ? secondAssetList : firstAssetList
    }
    
    var assetListView: BuyAssetListView {
        return tradeType.isBuy ? firstAssetList : secondAssetList
    }
    
    var walletList: Observable<[LWSpotWallet]> {
        return tradeType.isBuy ? payWithAssetListViewModel.payWithWalletList : tradingAssetsViewModel.availableToSell
    }
    
    var assetList: Observable<[LWAssetModel]> {
        return tradeType.isBuy ? tradingAssetsViewModel.availableToBuy : buyWithAssetListViewModel.buyWithAssetList
    }
    
    //MARK:- Lifecicle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstAssetList.itemPicker.picker.backgroundColor = #colorLiteral(red: 0, green: 0.431372549, blue: 0.3411764706, alpha: 1)
        secondAssetList.itemPicker.picker.backgroundColor = #colorLiteral(red: 0, green: 0.431372549, blue: 0.3411764706, alpha: 1)

        setupUX()
        
        buyOptimizedViewModel.bid.value = tradeType.isSell
        
        buyOptimizedViewModel
            .bindBuy(toView: assetListView, disposedBy: disposeBag)
        
        buyOptimizedViewModel
            .bindPayWith(toView: walletListView, disposedBy: disposeBag)
        
        buyOptimizedViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        walletListView.itemPicker.picker.rx.itemSelected
            .withLatestFrom(walletList) { selected, wallets in
                wallets.enumerated().first{$0.offset == selected.row}?.element
            }
            .filterNil()
            .map{(autoUpdated: false, wallet: $0)}
            .bind(to: buyOptimizedViewModel.payWithWallet)
            .disposed(by: disposeBag)
        
        walletList
            .map{$0.first}
            .filterNil()
            .map{(autoUpdated: true, wallet: $0)}
            .bind(to: buyOptimizedViewModel.payWithWallet)
            .disposed(by: disposeBag)
        
        walletList
            .bind(to: walletListView.itemPicker.picker.rx.itemAttributedTitles) { (_, wallet) in return NSAttributedString(string: wallet.asset.displayId, attributes: [NSForegroundColorAttributeName: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)]) }
            .disposed(by: disposeBag)
        
        assetListView.itemPicker.picker.rx.itemSelected
            .withLatestFrom(assetList) { selected, assets in
                assets.enumerated().first{$0.offset == selected.row}?.element
            }
            .filterNil()
            .map{(autoUpdated: false, asset: $0)}
            .bind(to: buyOptimizedViewModel.buyAsset)
            .disposed(by: disposeBag)
        
        assetList
            .map{$0.first}
            .filterNil()
            .map{(autoUpdated: true, asset: $0)}
            .bind(to: buyOptimizedViewModel.buyAsset)
            .disposed(by: disposeBag)
        
        assetList
            .bind(to: assetListView.itemPicker.picker.rx.itemAttributedTitles) { (_, asset) in return NSAttributedString(string: asset.displayId, attributes: [NSForegroundColorAttributeName: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)]) }
            .disposed(by: disposeBag)
        
        submitButton.rx.tap
            .flatMap { return PinViewController.presentOrderPinViewController(from: self, title: Localize("newDesign.enterPin"), isTouchIdEnabled: true) }
            .bind(to: confirmTrading)
            .disposed(by: disposeBag)
        
        let assetPairObservable = confirmTrading.asObserver()
            .map { [buyOptimizedViewModel] _ in (buyOptimizedViewModel.mainAsset, buyOptimizedViewModel.quotingAsset) }
            .filter { $0.0 != nil && $0.1 != nil }
            .flatMap { LWRxAuthManager.instance.assetPairs.request(baseAsset: $0.0!, quotingAsset: $0.1!) }
            .shareReplay(1)
        
        assetPairObservable
            .filter { $0.getError() != nil }
            .map { _ -> [AnyHashable: Any] in ["Message": "Unable to take asset pair"] }
            .asDriver(onErrorJustReturn: [:])
            .drive(rx.error)
            .disposed(by: disposeBag)
        
        let tradingObservable = assetPairObservable.filterSuccess()
            .filterNil()
            .flatMap { [buyOptimizedViewModel] assetPair -> Observable<ApiResult<LWAssetDealModel?>> in
                guard let asset = buyOptimizedViewModel.mainAsset, let isSell = buyOptimizedViewModel.bid.value, let amount = buyOptimizedViewModel.tradeAmount else {
                    return Observable.empty()
                }
                return LWMarketOrdersManager.createOrder(assetPair: assetPair, assetId: asset.identity, isSell: isSell, volume: String(describing: amount))
            }
            .shareReplay(1)
        
        tradingObservable
            .map { $0.getSuccess() }
            .filterNil()
            .map { $0 != nil }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: {[weak self] success in
                guard success else { return }
                FinalizePendingRequestsTrigger.instance.finalizeNow()
                guard let vc = self else { return }
                vc.buyOptimizedViewModel.buyAmount.value = BuyOptimizedViewModel.Amount(autoUpdated: true, value: "")
                vc.buyOptimizedViewModel.payWithAmount.value = BuyOptimizedViewModel.Amount(autoUpdated: true, value: "")
                vc.view.makeToast("Your exchange has been successfuly processed.It will appear in your transaction history soon.")
            })
            .disposed(by: disposeBag)

        loadingViewModel = LoadingViewModel([
            buyOptimizedViewModel.loadingViewModel.isLoading,
            tradingAssetsViewModel.loadingViewModel.isLoading,
            payWithAssetListViewModel.loadingViewModel.isLoading,
            assetPairObservable.isLoading(),
            tradingObservable.isLoading()
        ])
        
        loadingViewModel.isLoading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
        totalBalanceViewModel.isEmpty
            .drive(onNext: { [weak self] isEmpty in
                guard isEmpty, let `self` = self else { return }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let emptyWalletVC = storyboard.instantiateViewController(withIdentifier: "EmptyWallet") as! EmptyWalletViewController
                let messageKey = self.tradeType == .buy ? "emptyWallet.newDesign.buyMessage" : "emptyWallet.newDesign.sellMessage"
                emptyWalletVC.message = Localize(messageKey)
                self.rx.loading.onNext(false)
                self.navigationController?.setViewControllers([emptyWalletVC], animated: false)
            })
            .disposed(by: disposeBag)
        
        if let assetIdentifier = tradeAssetIdentifier {
            if tradeType.isBuy {
                assetList
                    .take(1)
                    .map { $0.filter { asset in return asset.identity == assetIdentifier }.first }
                    .filterNil()
                    .map{(autoUpdated: true, asset: $0)}
                    .bind(to: buyOptimizedViewModel.buyAsset)
                    .disposed(by: disposeBag)
            }
            else {
                walletList
                    .take(1)
                    .map { $0.filter { wallet in return wallet.asset.identity == assetIdentifier }.first }
                    .filterNil()
                    .map { (autoUpdated: true, wallet: $0) }
                    .bind(to: buyOptimizedViewModel.payWithWallet)
                    .disposed(by: disposeBag)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    enum TradeType {
        case buy, sell
        
        var isBuy: Bool {
            return self == .buy
        }
        
        var isSell: Bool {
            return self == .sell
        }
    }
    
}

extension Observable where Element == ApiResult<LWAssetDealModel?> {
    
    func isLoading() -> Observable<Bool> {
        return
            map { result -> Bool in
                if case .loading = result { return true }
                else { return false }
            }
    }
    
}

//MARK:- Binding
fileprivate extension ObservableType where Self.E == Void {
    
    func mapToTradeParams(withViewModel viewModel: BuyOptimizedViewModel) -> Observable<OffchainTradeViewModel.TradeParams> {
        return map{  _ -> OffchainTradeViewModel.TradeParams? in
            
            guard let asset = viewModel.mainAsset else { return nil }
            guard let forAsset = viewModel.quotingAsset else { return nil }
            
            return OffchainTradeViewModel.TradeParams(amount: viewModel.tradeAmount, asset: asset, forAsset: forAsset)
        }
        .filterNil()
    }
    
}

fileprivate extension OffchainTradeViewModel {
    
    func bind(toViewController vc: BuyOptimizedViewController) -> [Disposable] {
        return [
            errors.asObservable().bind(to: vc.rx.error),
            success.drive(onNext: {[weak vc] _ in
                vc?.buyOptimizedViewModel.buyAmount.value = BuyOptimizedViewModel.Amount(autoUpdated: true, value: "")
                vc?.buyOptimizedViewModel.payWithAmount.value = BuyOptimizedViewModel.Amount(autoUpdated: true, value: "")
            }),
            success.drive(onNext: {[weak vc] _ in
                FinalizePendingRequestsTrigger.instance.finalizeNow()
                vc?.view.makeToast("Your exchange has been successfuly processed.It will appear in your transaction history soon.")
            })
        ]
    }
}

fileprivate extension BuyOptimizedViewModel {
    
    func bind(toViewController vc: BuyOptimizedViewController) -> [Disposable] {
        return [
            isValidPayWithAmount
                .filterError()
                .map{ $0["Message"] as? String }
                .filterNil()
                .subscribe(onNext: { [weak vc] message in
                    vc?.view.makeToast(message, duration: 2.0, position: CSToastPositionTop)
                }),
            isValidPayWithAmount.map{ $0.isSuccess }.bind(to: vc.submitButton.rx.isEanbledWithBorderColor),
            spreadPercent.drive(vc.spreadPercent.rx.text),
            spreadAmount.drive(vc.spreadAmount.rx.text),
            bid.asDriver().filterNil().map{ $0 ? "SELL" : "PAY WITH" }.drive(vc.walletListView.label.rx.text),
            bid.asDriver().filterNil().map{ $0 ? "RECEIVE" : "BUY" }.drive(vc.assetListView.label.rx.text),
            bid.asDriver().filterNil().map{ $0 ? "SELL" : "BUY" }.drive(onNext: {vc.submitButton.setTitle($0, for: .normal)})
        ]
    }
    
    func bindBuy(toView view: BuyAssetListView, disposedBy disposeBag: DisposeBag) {
        
        baseAssetCode
            .drive(view.baseAssetCode.rx.text)
            .disposed(by: disposeBag)
        
        buyAssetIconURL
            .drive(view.assetIcon.rx.afImage)
            .disposed(by: disposeBag)
        
        buyAmountInBase
            .drive(view.amontInBase.rx.text)
            .disposed(by: disposeBag)
        
        buyAssetCode
            .drive(view.assetCode.rx.text)
            .disposed(by: disposeBag)

        (view.amount.rx.textInput <-> buyAmount)
            .disposed(by: disposeBag)
        
        buyAssetName
            .drive(view.assetName.rx.text)
            .disposed(by: disposeBag)
    }
    
    func bindPayWith(toView view: BuyAssetListView, disposedBy disposeBag: DisposeBag) {
        
        baseAssetCode
            .drive(view.baseAssetCode.rx.text)
            .disposed(by: disposeBag)
        
        payWithAssetIconURL
            .drive(view.assetIcon.rx.afImage)
            .disposed(by: disposeBag)
        
        payWithAmountInBase
            .drive(view.amontInBase.rx.text)
            .disposed(by: disposeBag)
        
        payWithAssetCode
            .drive(view.assetCode.rx.text)
            .disposed(by: disposeBag)
        
        (view.amount.rx.textInput <-> payWithAmount)
            .disposed(by: disposeBag)
        
        payWithAssetName
            .drive(view.assetName.rx.text)
            .disposed(by: disposeBag)
    }
    
}

extension BuyOptimizedViewModel {
    
    convenience init(withTrigger trigger: Observable<Void>) {
        self.init(
            trigger: trigger,
            dependency: (
                currencyExchanger: CurrencyExchanger(),
                authManager: LWRxAuthManager.instance
            )
        )
    }
    
}

//MARK:- Factory Methods
fileprivate extension BuyOptimizedViewController {
    
    func setupUX() {
        setupFormUX(disposedBy: disposeBag)
        firstAssetList.setupUX(width: view.frame.width, disposedBy: disposeBag)
        secondAssetList.setupUX(width: view.frame.width, disposedBy: disposeBag)
    }
    
}

// MARK: - Confort TextFieldNextDelegate Protocol
extension BuyOptimizedViewController: InputForm {
    
    var textFields: [UITextField] {
        return [
            firstAssetList.amount,
            secondAssetList.amount
        ]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return goToTextField(after: textField)
    }
    
}
