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
    
    lazy var currencyExchanger: CurrencyExchanger = {
        return CurrencyExchanger()
    } ()
    
    //MARK:- View Models
    lazy var buyOptimizedViewModel: BuyOptimizedViewModel = {
        return BuyOptimizedViewModel(
            withTrigger: self.confirmTrading,
            currencyExchanger: self.currencyExchanger
        )
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
    
    fileprivate lazy var walletsViewModel: WalletsViewModel = {
        return WalletsViewModel(
            refreshWallets: Observable<Void>.just(())
        )
    }()
    
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
            .bindBuy(toView: assetListView)
            .disposed(by: disposeBag)
        
        buyOptimizedViewModel
            .bindPayWith(toView: walletListView)
            .disposed(by: disposeBag)
        
        buyOptimizedViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        // Picker bindings
        walletList
            .map{ $0.map{ $0.asset } }
            .bind(toPickerView: walletListView.itemPicker.picker, assetIdentifierToSelect: tradeAssetIdentifier)
            .disposed(by: disposeBag)
        
        assetList
            .bind(toPickerView: assetListView.itemPicker.picker, assetIdentifierToSelect: tradeAssetIdentifier)
            .disposed(by: disposeBag)
        
        //Trading
        let assetPairObservable = buyOptimizedViewModel.confirm.asObservable()
            .filter { $0 }
            .map { [buyOptimizedViewModel] _ -> (baseAsset: LWAssetModel, quotingAsset: LWAssetModel)? in
                guard let baseAsset = buyOptimizedViewModel.mainAsset,
                    let quotingAsset = buyOptimizedViewModel.quotingAsset else { return nil }
                return (baseAsset: baseAsset, quotingAsset: quotingAsset)
            }
            .filterNil()
            .flatMap { LWRxAuthManager.instance.assetPairs.request(baseAsset: $0.baseAsset, quotingAsset: $0.quotingAsset) }
            .shareReplay(1)
        
        assetPairObservable
            .filterError()
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
            .filterSuccess()
            .filterNil()
            .map { _ in return true }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: {[weak self] success in
                guard success else { return }
                FinalizePendingRequestsTrigger.instance.finalizeNow()
                guard let viewController = self else { return }
                viewController.buyOptimizedViewModel.buyAmount.value = BuyOptimizedViewModel.Amount(autoUpdated: true, value: "", showErrorMsg: false)
                viewController.buyOptimizedViewModel.payWithAmount.value = BuyOptimizedViewModel.Amount(autoUpdated: true, value: "", showErrorMsg: false)
                viewController.view.makeToast(Localize("buy.newDesign.success"))
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
        
        walletsViewModel.isEmpty
            .waitFor(loadingViewModel.isLoading)
            .drive(onNext: { [weak self] isEmpty in
                guard isEmpty, let `self` = self else { return }
                let messageKey = self.tradeType == .buy ? "emptyWallet.newDesign.buyMessage" : "emptyWallet.newDesign.sellMessage"
                self.presentEmptyWallet(withMessage: Localize(messageKey))
            })
            .disposed(by: disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSummaryConfirmation" {
            guard let viewController = segue.destination as? ConfirmationViewController else { return }
            guard let amountFirst = firstAssetList.amount.text,
                let assetCodeFirst = firstAssetList.assetCode.text,
                let amountSecond = secondAssetList.amount.text,
                let assetCodeSecond = secondAssetList.assetCode.text,
                let firstLabel = firstAssetList.label.text,
                let secondLabel = secondAssetList.label.text
                else {
                    return
            }
            viewController.first = "\(amountFirst) \(assetCodeFirst)"
            viewController.second = "\(amountSecond) \(assetCodeSecond)"
            viewController.firstLabelText = firstLabel
            viewController.secondLabelText = secondLabel
            
            viewController.delegate = self
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

extension BuyOptimizedViewController: ConfirmationDelegate {
    func didConfirm(withViewController viewController: ConfirmationViewController) {
        viewController.dismiss(animated: true) {
            self.buyOptimizedViewModel.confirm.value = true
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

fileprivate extension ObservableType where Self.E == [LWAssetModel] {
    func bind(toPickerView pickerView: UIPickerView, assetIdentifierToSelect: String?) -> [Disposable] {
        return[
            //populate picker options
            bind(to: pickerView.rx.itemAttributedTitles) {
                    (_, asset) in return NSAttributedString(string: asset.displayId, attributes: [NSForegroundColorAttributeName: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
            },
            
            // set tradeAssetIdentifier as default
            map{[assetIdentifierToSelect] assets in
                assets.enumerated().first{ $1.identity == assetIdentifierToSelect }?.offset
            }
            .filterNil()
            .map{ (row: $0, component: 0) }
            .bind { [pickerView] data in
                pickerView.selectRow(data.row, inComponent: data.component, animated: false)
            }
        ]
    }
}

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
    
    func bind(toViewController viewController: BuyOptimizedViewController) -> [Disposable] {
        return [
            errors.asObservable().bind(to: viewController.rx.error),
            success.drive(onNext: {[weak viewController] _ in
                viewController?.buyOptimizedViewModel.buyAmount.value = BuyOptimizedViewModel.Amount(autoUpdated: true, value: "", showErrorMsg: false)
                viewController?.buyOptimizedViewModel.payWithAmount.value = BuyOptimizedViewModel.Amount(autoUpdated: true, value: "", showErrorMsg: false)
            }),
            success.drive(onNext: {[weak viewController] _ in
                FinalizePendingRequestsTrigger.instance.finalizeNow()
                viewController?.view.makeToast(Localize("buy.newDesign.success"))
            })
        ]
    }
}

fileprivate extension BuyOptimizedViewModel {
    
    func bind(toViewController viewController: BuyOptimizedViewController) -> [Disposable] {
        let assetIdentifier = viewController.tradeAssetIdentifier
        let tradeType = viewController.tradeType!
        
        return [
            //output
            isValidPayWithAmount
                .filterError()
                .map{ $0["Message"] as? String }
                .filterNil()
                .subscribe(onNext: { [weak viewController] message in
                    viewController?.view.makeToast(message, duration: 2.0, position: CSToastPositionTop)
                }),
            isValidPayWithAmount.map{ $0.isSuccess }.bind(to: viewController.submitButton.rx.isEanbledWithBorderColor),
            spreadPercent.drive(viewController.spreadPercent.rx.text),
            spreadAmount.drive(viewController.spreadAmount.rx.text),
            bid.asDriver().filterNil().map{ $0 ? "SELL" : "PAY WITH" }.drive(viewController.walletListView.label.rx.text),
            bid.asDriver().filterNil().map{ $0 ? "RECEIVE" : "BUY" }.drive(viewController.assetListView.label.rx.text),
            bid.asDriver().filterNil().map{ $0 ? "SELL" : "BUY" }.drive(viewController.submitButton.rx.title(for: .normal)),
            
            //input
            viewController.walletListView.itemPicker.picker.rx.itemSelected
                .withLatestFrom(viewController.walletList) { selected, wallets in
                    wallets.enumerated().first{$0.offset == selected.row}?.element
                }
                .filterNil()
                .map{(autoUpdated: false, wallet: $0)}
                .bind(to: payWithWallet),
            
            viewController.walletList
                .map{ wallets -> LWSpotWallet? in
                    tradeType.isSell && assetIdentifier != nil ?
                        (wallets.first { wallet in wallet.asset.identity == assetIdentifier } ?? wallets.first) :
                            wallets.first
                }
                .filterNil()
                .map{(autoUpdated: true, wallet: $0)}
                .bind(to: payWithWallet),
            
            viewController.assetListView.itemPicker.picker.rx.itemSelected
                .withLatestFrom(viewController.assetList) { selected, assets in
                    assets.enumerated().first{$0.offset == selected.row}?.element
                }
                .filterNil()
                .map{(autoUpdated: false, asset: $0)}
                .bind(to: buyAsset),
            
            viewController.assetList
                .map{ assets -> LWAssetModel? in
                    tradeType.isBuy && assetIdentifier != nil ?
                        (assets.first { asset in asset.identity == assetIdentifier } ?? assets.first) :
                            assets.first
                }
                .filterNil()
                .map{(autoUpdated: true, asset: $0)}
                .bind(to: buyAsset)
        ]
    }
    
    func bindBuy(toView view: BuyAssetListView) -> [Disposable] {
        return [
            baseAssetCode.drive(view.baseAssetCode.rx.text),
            buyAssetIconURL.drive(view.assetIcon.rx.afImage),
            buyAmountInBase.drive(view.amontInBase.rx.text),
            buyAssetCode.drive(view.assetCode.rx.text),
            (view.amount.rx.textInput <-> buyAmount),
            buyAssetName.drive(view.assetName.rx.text)
        ]
    }
    
    func bindPayWith(toView view: BuyAssetListView) -> [Disposable] {
        return [
            baseAssetCode.drive(view.baseAssetCode.rx.text),
            payWithAssetIconURL.debug("joro: test").drive(view.assetIcon.rx.afImage),
            payWithAmountInBase.drive(view.amontInBase.rx.text),
            payWithAssetCode.drive(view.assetCode.rx.text),
            (view.amount.rx.textInput <-> payWithAmount),
            payWithAssetName.drive(view.assetName.rx.text)
        ]
    }
    
}

extension BuyOptimizedViewModel {
    
    convenience init(withTrigger trigger: Observable<Void>, currencyExchanger: CurrencyExchanger = CurrencyExchanger()) {
        self.init(
            trigger: trigger,
            dependency: (
                currencyExchanger: currencyExchanger,
                authManager: LWRxAuthManager.instance,
                spreadService: SpreadService()
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
