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
    var requirePinForTrading = true
    var pinPassed = Variable(false)
    
    lazy var buyOptimizedViewModel: BuyOptimizedViewModel = {
        return BuyOptimizedViewModel(withTrigger: self.confirmTrading)
    }()
    
    lazy var payWithAssetListViewModel: PayWithAssetListViewModel = {
        return PayWithAssetListViewModel(buyAsset: self.buyOptimizedViewModel.buyAsset.asObservable().mapToAsset())
    }()
    
    lazy var tradingAssetsViewModel: TradingAssetsViewModel = {
        return TradingAssetsViewModel()
    }()
    
    lazy var loadingViewModel: LoadingViewModel = {
        return LoadingViewModel([
            self.tradingAssetsViewModel.loadingViewModel.isLoading,
            self.payWithAssetListViewModel.loadingViewModel.isLoading,
            self.offchainTradeViewModel.loadingViewModel.isLoading
        ])
    }()
    
    lazy var offchainTradeViewModel: OffchainTradeViewModel = {
        return OffchainTradeViewModel(offchainService: OffchainService.instance)
    }()
    
    var confirmTrading: Observable<Void> {
        return Observable.merge(
            self.submitButton.rx.tap.asObservable()
                .filter{[weak self] in !(self?.requirePinForTrading ?? false)},
            self.pinPassed.asObservable()
                .filter{$0}
                .map{_ in Void()}
        )
    }
    
    let bid = Variable<Bool?>(nil)
    
    fileprivate let disposeBag = DisposeBag()
    
    //MARK:- Lifecicle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUX()
        
        buyOptimizedViewModel.bid.value = false
        
        secondAssetList.itemPicker.picker.rx.itemSelected
            .withLatestFrom(payWithAssetListViewModel.payWithWalletList) {selected, assets in
                assets.enumerated().first{$0.offset == selected.row}?.element
            }
            .filterNil()
            .map{(autoUpdated: false, wallet: $0)}
            .bind(to: buyOptimizedViewModel.payWithWallet)
            .disposed(by: disposeBag)
        
        firstAssetList.itemPicker.picker.rx.itemSelected
            .withLatestFrom(tradingAssetsViewModel.availableToBuy) {selected, assets in
                assets.enumerated().first{$0.offset == selected.row}?.element
            }
            .filterNil()
            .map{(autoUpdated: false, asset: $0)}
            .bind(to: buyOptimizedViewModel.buyAsset)
            .disposed(by: disposeBag)
        
        buyOptimizedViewModel.bindBuy(toView: firstAssetList, disposedBy: disposeBag)
        buyOptimizedViewModel.bindPayWith(toView: secondAssetList, disposedBy: disposeBag)
        
        payWithAssetListViewModel.payWithWalletList
            .map{$0.first}
            .filterNil()
            .map{(autoUpdated: true, wallet: $0)}
            .bind(to: buyOptimizedViewModel.payWithWallet)
            .disposed(by: disposeBag)
        
        tradingAssetsViewModel.availableToBuy
            .map{$0.first}
            .filterNil()
            .map{(autoUpdated: true, asset: $0)}
            .bind(to: buyOptimizedViewModel.buyAsset)
            .disposed(by: disposeBag)
        
        payWithAssetListViewModel.payWithWalletList
            .bind(to: secondAssetList.itemPicker.picker.rx.itemTitles) {$1.asset.displayFullName}
            .disposed(by: disposeBag)
        
        tradingAssetsViewModel.availableToBuy
            .bind(to: firstAssetList.itemPicker.picker.rx.itemTitles) {$1.displayFullName}
            .disposed(by: disposeBag)
    
        buyOptimizedViewModel.spreadPercent
            .drive(spreadPercent.rx.text)
            .disposed(by: disposeBag)
        
        buyOptimizedViewModel.spreadAmount
            .drive(spreadAmount.rx.text)
            .disposed(by: disposeBag)
        
        submitButton.rx.tap
            .subscribeToPresentPin(withViewController: self)
            .disposed(by: disposeBag)

        confirmTrading
            .map{ [weak self]_ -> OffchainTradeViewModel.TradeParams? in
                
                guard let `self` = self else {return nil}
                guard let payWithWallet = self.buyOptimizedViewModel.payWithWallet.value?.wallet else{ return nil }
                guard let buyAsset = self.buyOptimizedViewModel.buyAsset.value?.asset else{ return nil }
                let amount = self.buyOptimizedViewModel.buyAmount.value.value.decimalValue
                
                return OffchainTradeViewModel.TradeParams(amount: amount, wallet: payWithWallet, forAsset: buyAsset)
            }
            .filterNil()
            .bind(to: offchainTradeViewModel.tradeParams)
            .disposed(by: disposeBag)
        
        offchainTradeViewModel.errors.asObservable()
            .bind(to: self.rx.error)
            .disposed(by: disposeBag)
        
        
        loadingViewModel.isLoading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
        buyOptimizedViewModel.isValidPayWithAmount
            .bind(to: submitButton.rx.isEanbledWithBorderColor)
            .disposed(by: disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK:- Binding
fileprivate extension TradingAssetsViewModel {
//    func bindToBuy(toView view: BuyAssetListView, disposedBy disposeBag: DisposeBag) {
//        availableToBuy
//            .bind(to: view.itemPicker.picker.rx.itemTitles) {$1.identity}
//            .disposed(by: disposeBag)
//    }
//
//    func bindToBuy(toViewModel viewModel: BuyOptimizedViewModel, disposedBy disposeBag: DisposeBag) {
//        availableToBuy
//            .map{$0.first}
//            .bind(to: viewModel.buyAsset)
//            .disposed(by: disposeBag)
//    }
}

fileprivate extension BuyOptimizedViewModel {
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

        view.label.text = "BUY"
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
        
        view.label.text = "PAY WITH"
    }
}

extension BuyOptimizedViewModel {
    convenience init(withTrigger trigger: Observable<Void>) {
        self.init(
            trigger: trigger,
            dependency: (
                currencyExchanger: CurrencyExchanger(),
                authManager: LWRxAuthManager.instance,
                offchainManager: LWOffchainTransactionsManager.shared(),
                ethereumManager: LWEthereumTransactionsManager.shared()
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

// MARK: - Confort PIN Protocols
extension BuyOptimizedViewController: PinViewControllerDelegate {
    func isPinCorrect(_ success: Bool, pinController: PinViewController) {
        guard success else {return}
        self.pinPassed.value = success
        pinController.dismiss(animated: true)
    }
    
    func isTouchIdCorrect(_ success: Bool, pinController: PinViewController) {
        guard success else {return}
        self.pinPassed.value = success
        pinController.dismiss(animated: true)
    }
}

extension BuyOptimizedViewController: PinAwarePresenter{}

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
