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
    
    var textFields: [UITextField]! {
        return [
            self.firstAssetList.amount,
            self.secondAssetList.amount
        ]
    }
    
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
    
    let offchainService = OffchainService(
        authManager: LWRxAuthManager.instance,
        privateKeyManager: LWPrivateKeyManager.shared(),
        keychainManager: LWKeychainManager.instance()
    )
    
    fileprivate let disposeBag = DisposeBag()
    
    //MARK:- Lifecicle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUX()
        
        buyOptimizedViewModel.bid.value = false
        
        secondAssetList.itemPicker.picker.rx.itemSelected
            .withLatestFrom(payWithAssetListViewModel.payWithAssetList) {selected, assets in
                assets.enumerated().first{$0.offset == selected.row}?.element
            }
            .filterNil()
            .map{(autoUpdated: false, asset: $0)}
            .bind(to: buyOptimizedViewModel.payWithAsset)
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
        
        payWithAssetListViewModel.payWithAssetList
            .map{$0.first}
            .filterNil()
            .map{(autoUpdated: true, asset: $0)}
            .bind(to: buyOptimizedViewModel.payWithAsset)
            .disposed(by: disposeBag)
        
        tradingAssetsViewModel.availableToBuy
            .map{$0.first}
            .filterNil()
            .map{(autoUpdated: true, asset: $0)}
            .bind(to: buyOptimizedViewModel.buyAsset)
            .disposed(by: disposeBag)
        
        payWithAssetListViewModel.payWithAssetList
            .bind(to: secondAssetList.itemPicker.picker.rx.itemTitles) {$1.displayFullName}
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
            .map{[weak self] _ -> String? in
                guard let `self` = self else {return nil}
                guard let buyAsset = self.buyOptimizedViewModel.buyAsset.value?.asset else{return nil}
                guard let payWithAsset = self.buyOptimizedViewModel.payWithAsset.value?.asset else{return nil}
                guard let volume = self.buyOptimizedViewModel.buyAmount.value.value.decimalValue else {return nil}
                
                self.offchainService.trade(amount: volume, asset: buyAsset, forAsset: payWithAsset)
                
                return ""
            }
            .subscribe(onNext: {_ in
                
            })
            .disposed(by: disposeBag)
        
        
            
//            .filterNil()
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
        scrollView.subscribeKeyBoard(withDisposeBag: disposeBag)
        
        firstAssetList.amount.delegate = self
        secondAssetList.amount.delegate = self
        
        firstAssetList.setupUX(withButtonTitle: Localize("Next"), disposedBy: disposeBag)
        secondAssetList.setupUX(withButtonTitle: Localize("buy.newDesign.done"), disposedBy: disposeBag)
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
extension BuyOptimizedViewController: TextFieldNextDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return goToNextField(withCurrentField: textField)
    }
}
