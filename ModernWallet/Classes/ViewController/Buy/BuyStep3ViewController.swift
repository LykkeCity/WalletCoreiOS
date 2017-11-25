//
//  BuyStep3ViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class BuyStep3ViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate {
    
    
    // MARK: - Outlets
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var buyWithCurrencyLbl: UILabel!
    @IBOutlet weak var unitsValue: UILabel!
    @IBOutlet weak var unitsTitle: UILabel!
    @IBOutlet weak var unitsCurrency: UILabel!
    @IBOutlet weak var unitsAmount : UITextField!
    @IBOutlet weak var priceCurrency: UILabel!
    @IBOutlet weak var totalCurrency: UILabel!
    @IBOutlet weak var totalValue: UILabel!
    @IBOutlet weak var buyWithAvLbl: UILabel!
    @IBOutlet weak var buyWithValue: UILabel!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var priceValue: UILabel!
    @IBOutlet weak var priceAmount: UILabel!
    
    
    // MARK: - Properties
    var dataPicker : UIPickerView = UIPickerView()
    var txtField: UITextField = UITextField()
    var disposeBag = DisposeBag()
    let authManager: LWRxAuthManager = LWRxAuthManager.instance
    let currencyChanger : CurrencyExchanger = CurrencyExchanger()
    var askOrBid: Bool = false
    var requirePinForTrading = true
    var pinPassed = Variable(false)
    var assetPairModel: LWAssetPairModel = LWAssetPairModel()
    let assetModel = Variable<LWAssetModel?>(nil)
    let wallet = Variable<LWSpotWallet?>(nil)
    let wallets = Variable<[LWSpotWallet]>([])
    let bid = Variable<Bool?>(nil)
    lazy var viewModel: BuyStep3ViewModel = self.viewModelFactory()
    
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //this is hardcoded
//        let decryptPrivateKeyManager = LWPrivateKeyManager.shared()
//        decryptPrivateKeyManager?.decryptLykkePrivateKeyAndSave("5b98a88a4a542ad6d76784b172db9e62001412da420b3d7874bc2998eec93145b45d1e69fd4aa1eff683a40a821676dbb622a29dcda184cd41d80e21375133a8")
        
        confirmBtn.layer.borderWidth = 1.0
        confirmBtn.layer.borderColor =  UIColor.white.cgColor
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clear

        txtField.inputView = dataPicker
        self.view.addSubview(txtField)
//        addDoneButton(txtField, selector: #selector(doneAction))
//        addDoneButton(unitsAmount, selector: #selector(doneUnitsAction))
        
        unitsAmount.attributedPlaceholder = NSAttributedString(string: "0.0",
                                                               attributes: [NSForegroundColorAttributeName: UIColor.white])
        
        fillViewModelInput()
        addBindings()
        
        viewModel.tradeResult
            .filterError()
            .subscribe(onNext: {[weak self] error in
                guard let `self` = self else {return}
                self.show(error: error)
            })
            .disposed(by: disposeBag)
        
        viewModel.loadingViewModel.isLoading
            .bind(to: self.rx.loading)
            .disposed(by: disposeBag)
        
        confirmBtn.rx.tap.asObservable()
            .subscribeToPresentPin(withViewController: self)
            .disposed(by: disposeBag)
    }
    
    func updateBuyCurrency() {
        print("Update buy currency")
    }
    
    func getAskOrBid() -> Bool {
        return askOrBid
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func doneUnitsAction() {
        unitsAmount.resignFirstResponder()
    }
    
    func doneAction() {
        txtField.resignFirstResponder()
    }
    
    @IBAction func showPicker(_ sender: UIButton) {
        txtField.becomeFirstResponder()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        txtField.resignFirstResponder()
    }
    

    @IBAction func confirmAction(_ sender: UIButton) {
        
//        guard let unitsAmaountValue = Double(unitsAmount.text!) else {return}
//        guard unitsAmount.text != "" && buyWithCurrencyLbl.text != "" && unitsAmaountValue>0 else {return}
//        guard let buyStep4VC = UIStoryboard.init(name: "Buy", bundle: nil).instantiateViewController(withIdentifier: "BuyStep4")
//            as? BuyStep4ViewController else {return}
//        
//        buyStep4VC.dict = ["UnitsValue":unitsValue.textOrEmpty,
//                           "UnitsAmount":unitsAmount.textOrEmpty,
//                           "UnitsCurrency":unitsCurrency.textOrEmpty,
//                           "PriceValue" : priceValue.textOrEmpty,
//                           "PriceAmount": priceAmount.textOrEmpty,
//                           "PriceCurrency": priceCurrency.textOrEmpty,
//                           "TotalCurrency": totalCurrency.textOrEmpty,
//                           "TotalValue": totalValue.textOrEmpty,
//                           "TotalAmount": totalAmount.textOrEmpty,
//                           "BuyWithCurrency": buyWithCurrencyLbl.textOrEmpty,
//                           "BuywithValue": buyWithValue.textOrEmpty]
//        
//        guard let firstAssetModel = getCurrentWalletAsset(), let secondAssetModel = assetModel.value else{return}
//        guard let assetPairModel = getCurrentPairAsset(firstAssetModel, secondAsset: secondAssetModel) else {return}
//        
//        self.setLoading(true)
//        //Buying with eth
//        if firstAssetModel.blockchainType != BLOCKCHAIN_TYPE_ETHEREUM && secondAssetModel.blockchainType != BLOCKCHAIN_TYPE_ETHEREUM {
//            
//            let offchainTransactionManager = LWOffchainTransactionsManager.shared()
//            offchainTransactionManager?.sendSwapRequest(forAsset: firstAssetModel.identity, pair: assetPairModel.identity, volume: unitsAmaountValue, completion: {
//                [weak self] result in
//                self?.setLoading(false)
//                if result == nil {
//                    self?.view.makeToast("There was problem with buying!")
//                }else {
//                    self?.navigationController?.pushViewController(buyStep4VC, animated: true)
//                }
//            })
//        }
//        else {
//            //Buying with other currencies
//            let volumeNumber = NSNumber.init(value: unitsAmaountValue)
//            let transManager = LWEthereumTransactionsManager.shared()
//            transManager?.requestTrade(forBaseAsset: assetModel.value, pair: assetPairModel, addressTo: "", volume: volumeNumber, completion: {[weak self] result in
//                self?.setLoading(false)
//                self?.navigationController?.pushViewController(buyStep4VC, animated: true)
//            })
//        }
    }
    
//    func getCurrentWalletAsset()->LWAssetModel? {
//        for wallet in wallets.value {
//            if wallet.identity == buyWithCurrencyLbl.text  {
//                return wallet.asset
//            }
//        }
//        
//        return nil
//    }
//    
//    func getCurrentPairAsset(_ firstAsset: LWAssetModel, secondAsset: LWAssetModel)->LWAssetPairModel? {
//        if let cache = LWCache.instance() {
//            for assetPair in cache.allAssetPairs {
//                if let assetPairModelTmp = assetPair as? LWAssetPairModel {
//                    print(assetPairModelTmp.baseAssetId, assetPairModelTmp.quotingAssetId)
//                    if (assetPairModelTmp.baseAssetId == firstAsset.identity && assetPairModelTmp.quotingAssetId == secondAsset.identity) || (assetPairModelTmp.baseAssetId == secondAsset.identity && assetPairModelTmp.quotingAssetId == firstAsset.identity) {
//                        return assetPairModelTmp
//                    }
//                }
//            }
//        }
//        return nil
//    }
}


// MARK: - Delegates
extension BuyStep3ViewController: PinViewControllerDelegate {
    func isPinCorrect(_ success: Bool, pinController: PinViewController) {
        self.pinPassed.value = true
        pinController.dismiss(animated: true)
    }
}

// MARK: - Bindings
fileprivate extension BuyStep3ViewController {
    
    func addBindings() {
        viewModel.unitsInBaseAsset
            .drive(unitsValue.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.assetName
            .drive(unitsCurrency.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.priceInBaseAsset
            .drive(priceValue.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.price
            .drive(priceAmount.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.walletTotal
            .drive(totalAmount.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.walletTotalAv
            .drive(buyWithAvLbl.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.walletTotalInBaseAsset
            .drive(totalValue.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.walletAssetCode
            .drive(buyWithCurrencyLbl.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.walletAssetCode
            .drive(priceCurrency.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.walletAssetCode
            .drive(totalCurrency.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.currentPriceCurrencyInBaseAsset
            .drive(buyWithValue.rx.text)
            .disposed(by: disposeBag)
        
    }
    
    func fillViewModelInput() {
        bid.value =  getAskOrBid()
        
        viewModel.nonEmptyWallets
            .bind(to: wallets)
            .disposed(by: disposeBag)
        
        wallets.asObservable()
            .bind(to: dataPicker.rx.itemTitles) { (row, element) in
                return element.identity
            }
            .disposed(by: disposeBag)
        
        dataPicker.rx.itemSelected.asObservable()
            .filter{[weak self] _ in self?.wallets.value.isNotEmpty ?? false}
            .map{$0.row}
            .filter{[weak self] in $0 < self?.wallets.value.endIndex ?? 0}
            .map{[weak self] in self?.wallets.value[$0]}.filterNil()
            .bind(to: self.wallet)
            .disposed(by: disposeBag)
        
        //TODO: To be implemented
        authManager.allAssets.request(byId: self.assetPairModel.baseAssetId)
            .filterSuccess()
            .filterNil()
            .bind(to: assetModel)
            .disposed(by: disposeBag)
        
        wallets.asObservable()
            .map{[weak self] wallets -> LWSpotWallet? in
                return wallets.first{(wallet: LWSpotWallet) in
                    return wallet.asset.identity == self?.assetPairModel.quotingAssetId
                }
            }
            .bind(to: wallet)
            .disposed(by: disposeBag)
    }
}


// MARK: - Factories
fileprivate extension BuyStep3ViewController {
    func viewModelFactory() -> BuyStep3ViewModel {
        
        let unitsObservable = unitsAmount.rx.textInput.text.asObservable()
            .replaceNilWith("0.0")
            .map{Decimal(string: $0)}
            .replaceNilWith(0.0)
            .shareReplay(1)
        
        
        let assetModelObservable = assetModel.asObservable().filterNil().shareReplay(1)
        let walletObservable = wallet.asObservable().filterNil().shareReplay(1)
        let bidObservable = bid.asObservable().filterNil().shareReplay(1)
        let confirmTrading = Observable.merge(
            confirmBtn.rx.tap.asObservable().filter{[weak self] in
                guard let `self` = self else {return false}
                return !self.requirePinForTrading
            },
            pinPassed.asObservable()
                .filter{$0}
                .map{_ in Void()}
        )
        
        return BuyStep3ViewModel(
            input: (
                units:      unitsObservable,
                asset:      assetModelObservable,
                wallet:     walletObservable,
                bid:        bidObservable,
                submit:     confirmTrading
            ),
            dependency: (
                currencyExchanger: CurrencyExchanger(),
                authManager: LWRxAuthManager.instance,
                offchainManager: LWOffchainTransactionsManager.shared(),
                ethereumManager: LWEthereumTransactionsManager.shared()
            )
        )
    }
}


// MARK: - RX
extension ObservableType where Self.E == Void {
    func subscribeToPresentPin<ViewController: UIViewController>(withViewController vc: ViewController) -> Disposable
        where ViewController:PinAwarePresenter & PinViewControllerDelegate {
        return filter{[weak vc] in
            guard let vc = vc else {return false}
            return vc.requirePinForTrading
        }
        .map{[weak vc] in
            vc?.storyboard?.instantiateViewController(withIdentifier: "buyPinVC") as? UINavigationController
        }
        .filterNil()
        .map{(
            navController: $0,
            controller: $0.childViewControllers.first as? BuyPinViewController
        )}
        .subscribe(onNext: {[weak vc] controllers in
            vc?.present(controllers.navController, animated: true) {
                controllers.controller?.delegate = vc
            }
        })
    }
}

extension BuyStep3ViewController: PinAwarePresenter{}

// MARK: - Utilities
fileprivate extension UILabel {
    var textOrEmpty: String {
        return self.text ?? ""
    }
}

fileprivate extension UITextField {
    var textOrEmpty: String {
        return self.text ?? ""
    }
}
