//
//  SendToWalletViewController.swift
//  ModernMoney
//
//  Created by Vasil Garov on 12/12/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import UIKit
import WalletCore
import QRCodeReader
import AVFoundation
import TextFieldEffects
import RxSwift
import RxCocoa

class SendToWalletViewController: UIViewController {
    
    @IBOutlet weak var walletAddressTextField: HoshiTextField!
    @IBOutlet weak var amountTextField: HoshiTextField!
    @IBOutlet weak var proceedButton: SubmitButton!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var pasteButton: UIButton!
    @IBOutlet weak var currencyLabel: UILabel!
    
    var asset: Variable<Asset>!
    
    var confirmTrading = PublishSubject<Void>()
    
    private let disposeBag = DisposeBag()
    
    private lazy var viewModel: CashOutToAddressViewModel = {
        return CashOutToAddressViewModel(trigger: self.confirmTrading)
    }()
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
            $0.showTorchButton = true
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        setupUI()
    }
    
    @IBAction func scanTapped(_ sender: Any) {
        readerVC.modalPresentationStyle = .formSheet
        readerVC.delegate = self
        
        readerVC.completionBlock = {[weak self] (result: QRCodeReaderResult?) in
            if let result = result {
                self?.walletAddressTextField.text = result.value
            }
        }
        
        present(readerVC, animated: true, completion: nil)
    }
    
    @IBAction func pasteTapped(_ sender: Any) {
        walletAddressTextField.text = UIPasteboard.general.string
    }
    
    private func setupUI() {
        headingLabel.text = Localize("send.newDesign.selectWalletForTransfer")
        proceedButton.setTitle(Localize("send.newDesign.proceed"), for: .normal)
        walletAddressTextField.placeholder = Localize("send.newDesign.enterWalletAddress")
        pasteButton.setTitle(Localize("send.newDesign.paste"), for: .normal)
        navigationItem.title = Localize("send.newDesign.navigationTitle")
        
        amountTextField.text = Decimal(0.0).convertAsCurrency(code: "",
                                                            symbol: "",
                                                            accuracy: asset?.value.wallet?.asset.accuracy.intValue ?? 0)
        currencyLabel.text = asset?.value.wallet?.symbol
    }
}

// MARK: QRCodeReader Delegate
extension SendToWalletViewController: QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
}

// MARK: Input form Delegate
extension SendToWalletViewController: InputForm {
    
    var submitButton: UIButton! {
        return proceedButton
    }
    
    var textFields: [UITextField] {
        return [
            walletAddressTextField,
            amountTextField
        ]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return goToTextField(after: textField)
    }
    
}

fileprivate extension CashOutToAddressViewModel {
    func bind(toViewController vc: SendToWalletViewController) -> [Disposable] {
        return [
            vc.amountTextField.rx.text.asObservable()
                .replaceNilWith("0.0")
                .map{ $0.decimalValue }
                .filterNil()
                .bind(to: amount),
            
            vc.walletAddressTextField.rx.text.asObservable()
                .replaceNilWith("")
                .bind(to: address),
            
            vc.asset.asObservable()
                .map{ $0.wallet?.asset.identity }
                .filterNil()
                .bind(to: assetId),
            
            vc.submitButton.rx.tap
                .flatMap { _ in return PinViewController.presentOrderPinViewController(from: vc, title: Localize("newDesign.enterPin"), isTouchIdEnabled: true) }
                .bind(to: vc.confirmTrading),
            
            loadingViewModel.isLoading
                .bind(to: vc.rx.loading),
            
            errors.drive(vc.rx.error),
            
            success.drive(onNext: { [weak vc] message in
                vc?.navigationController?.parent?.view.makeToast(message)
                vc?.navigationController?.popViewController(animated: true)
            })
        ]
    }
}
