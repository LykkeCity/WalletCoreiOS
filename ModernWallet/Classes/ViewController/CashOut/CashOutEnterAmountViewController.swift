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
    @IBOutlet private weak var scrollView: UIScrollView!
    
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
    @IBOutlet private weak var confirmSlider: ConfirmSlider!
    
    var assetIdentity: String!
    
    private lazy var walletViewModel: WalletViewModel = {
        return WalletViewModel(
            assetIdentity: self.assetIdentity,
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
        
        setupUX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        confirmSlider.value = false
    }
    
    // MARK: - IBActions

    @IBAction private func confirmSliderChanged(_ slider: ConfirmSlider) {
        if slider.value {
            performSubmit()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Private

    private func setupUX() {
        scrollView.subscribeKeyBoard(withDisposeBag: disposeBag)
        
        assetAmountTextField.delegate = self
        baseAmountTextField.delegate = self
        
        addButton(forField: assetAmountTextField, withTitle: Localize("newDesign.next"))
            .subscribe(onNext: { [weak self] textField in
                _ = self?.goToNextField(withCurrentField: textField)
            })
            .disposed(by: disposeBag)
        addDoneButton(baseAmountTextField, selector: #selector(CashOutEnterAmountViewController.performSubmit))
    }
    
}

extension CashOutEnterAmountViewController: TextFieldNextDelegate {

    var submitButton: UIButton! {
        return nil
    }
    
    var textFields: [UITextField]! {
        return [ assetAmountTextField, baseAmountTextField ]
    }
    
    @objc func performSubmit() {
        textFields.forEach { $0.resignFirstResponder() }
        performSegue(withIdentifier: "NextStep", sender: nil)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return goToNextField(withCurrentField: textField)
    }
    
}
