//
//  CashOutEnterAmountViewController.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 17.10.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit
import RxSwift
import WalletCore

class CashOutEnterAmountViewController: UIViewController {
    
    @IBOutlet private weak var backgroundHeightConstraint: NSLayoutConstraint!
    @IBOutlet internal weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var assetImageView: UIImageView!
    @IBOutlet private weak var assetNameLabel: UILabel!
    @IBOutlet private weak var assetAmountView: AssetAmountView!
    @IBOutlet private weak var percentLabel: UILabel!
    @IBOutlet private weak var baseAssetAmountView: AssetAmountView!
    
    @IBOutlet private weak var enterAmountLabel: UILabel!
    @IBOutlet private weak var baseAssetCodeLabel: UILabel!
    @IBOutlet fileprivate weak var baseAmountTextField: UITextField!
    @IBOutlet private weak var assetCodeLabel: UILabel!
    @IBOutlet fileprivate weak var assetAmountTextField: UITextField!
    
    @IBOutlet private weak var slideToRetrieveLabel: UILabel!
    @IBOutlet fileprivate weak var confirmSlider: ConfirmSlider!
    
    var walletObservable: Observable<LWSpotWallet>!
    
    private lazy var walletViewModel: WalletViewModel = {
        return WalletViewModel(
            refresh: Observable<Void>.interval(10.0),
            wallet: self.walletObservable,
            dependency: (
                currencyExchanger: CurrencyExchanger(),
                authManager: LWRxAuthManager.instance
            )
        )
    }()
    
    lazy var buyOptimizedViewModel: BuyOptimizedViewModel = {
        return BuyOptimizedViewModel(withTrigger: Observable.empty())
    }()
    
    private var disposeBag = DisposeBag()
    
    fileprivate lazy var cashOutViewModel = CashOutViewModel(
        amountViewModel: CashOutAmountViewModel(walletObservable: self.walletObservable),
        generalViewModel: CashOutGeneralViewModel(),
        bankAccountViewModel: CashOutBankAccountViewModel(),
        currencyExchanger: CurrencyExchanger(refresh: Observable<Void>.interval(10.0))
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundHeightConstraint.constant = Display.height
        
        enterAmountLabel.text = Localize("cashOut.newDesign.enterAmount")
        slideToRetrieveLabel.text = Localize("cashOut.newDesign.slideToRetrieve")
        
        baseAssetAmountView.amountFont = UIFont(name: "Geomanist-Light", size: 20.0)
        assetAmountView.amountFont = UIFont(name: "Geomanist-Light", size: 14.0)
        
        walletViewModel.assetIconUrl
            .distinctUntilChanged()
            .drive(assetImageView.rx.afImage)
            .disposed(by: disposeBag)
        
        walletViewModel.assetName
            .drive(assetNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        walletViewModel.driveAmount(to: assetAmountView)
            .disposed(by: disposeBag)
        
        walletViewModel.percent
            .drive(percentLabel.rx.text)
            .disposed(by: disposeBag)
        
        walletViewModel.driveAmountInBase(to: baseAssetAmountView)
            .disposed(by: disposeBag)
        
        walletViewModel.assetObservable
            .map { BuyOptimizedViewModel.Asset(autoUpdated: false, asset: $0) }
            .bind(to: buyOptimizedViewModel.payWithAsset)
            .disposed(by: disposeBag)
        
        walletViewModel.baseAssetObservable
            .map { BuyOptimizedViewModel.Asset(autoUpdated: true, asset: $0) }
            .bind(to: buyOptimizedViewModel.buyAsset)
            .disposed(by: disposeBag)
        
        buyOptimizedViewModel.payWithAssetCode
            .drive(assetCodeLabel.rx.text)
            .disposed(by: disposeBag)
        
        (assetAmountTextField.rx.textInput <-> buyOptimizedViewModel.payWithAmount)
            .disposed(by: disposeBag)
        
        buyOptimizedViewModel.bid.value = false
        
        buyOptimizedViewModel.buyAssetCode
            .drive(baseAssetCodeLabel.rx.text)
            .disposed(by: disposeBag)
        
        (baseAmountTextField.rx.textInput <-> buyOptimizedViewModel.buyAmount)
            .disposed(by: disposeBag)
        
        buyOptimizedViewModel.buyAmount
            .asObservable()
            .subscribe()
            .disposed(by: disposeBag)
        
        buyOptimizedViewModel.payWithAmount
            .asObservable()
            .subscribe()
            .disposed(by: disposeBag)
        
        let amountViewModel = cashOutViewModel.amountViewModel
        
        Observable.combineLatest(walletObservable, assetAmountTextField.rx.text.filterNil())
            .map { (data) -> Decimal in
                let (wallet, amountString) = data
                var amount = amountString.decimalValue ?? 0
                var roundedAmount = Decimal()
                NSDecimalRound(&roundedAmount, &amount, wallet.asset.accuracy.intValue, .bankers)
                return roundedAmount
            }
            .bind(to: amountViewModel.amount)
            .disposed(by: disposeBag)
        
        amountViewModel.isValid.asDriver(onErrorJustReturn: false)
            .drive(confirmSlider.rx.isEnabled)
            .disposed(by: disposeBag)
        
        setupFormUX(disposedBy: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        confirmSlider.value = false
    }
    
    // MARK: - IBActions

    @IBAction private func confirmSliderChanged(_ slider: ConfirmSlider) {
        if slider.value {
            submitForm()
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NextStep" {
            guard let vc = segue.destination as? CashOutPersonalDetailsViewController else {
                return
            }
            vc.cashOutViewModel = cashOutViewModel
        }
    }
    
}

extension CashOutEnterAmountViewController: InputForm {
    
    var textFields: [UITextField] {
        return [
            assetAmountTextField,
            baseAmountTextField
        ]
    }
    
    func submitForm() {
        guard confirmSlider.isEnabled else { return }
        performSegue(withIdentifier: "NextStep", sender: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return goToTextField(after: textField)
    }
    
}

extension WalletViewModel {
    
    func driveAmount(to view: AssetAmountView) -> [Disposable] {
        return [
            assetAmount.drive(view.rx.amount),
            assetCode.drive(view.rx.code)
        ]
    }
    
    func driveAmountInBase(to view: AssetAmountView) -> [Disposable] {
        return [
            inBaseAssetAmount.drive(view.rx.amount),
            baseAssetCode.drive(view.rx.code)
        ]
    }
    
}
