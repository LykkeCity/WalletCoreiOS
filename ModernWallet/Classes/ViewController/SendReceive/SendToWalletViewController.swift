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

class SendToWalletViewController: UIViewController {
    
    @IBOutlet weak var walletAddress: HoshiTextField!
    @IBOutlet weak var amount: HoshiTextField!
    @IBOutlet weak var proceed: SubmitButton!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var paste: UIButton!
    
    var asset: Variable<Asset>?
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
            $0.showTorchButton = true
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    @IBAction func scanTapped(_ sender: Any) {
        readerVC.modalPresentationStyle = .formSheet
        readerVC.delegate = self
        
        readerVC.completionBlock = {[weak self] (result: QRCodeReaderResult?) in
            if let result = result {
                self?.walletAddress.text = result.value
            }
        }
        
        present(readerVC, animated: true, completion: nil)
    }
    
    @IBAction func pasteTapped(_ sender: Any) {
        walletAddress.text = UIPasteboard.general.string
    }
    
    private func setupUI() {
        headingLabel.text = Localize("send.newDesign.selectWalletForTransfer")
        proceed.setTitle(Localize("send.newDesign.proceed"), for: .normal)
        walletAddress.placeholder = Localize("send.newDesign.enterWalletAddress")
        paste.setTitle(Localize("send.newDesign.paste"), for: .normal)
        navigationItem.title = Localize("send.newDesign.navigationTitle")
        
        amount.text = Decimal(0.0).convertAsCurrency(code: "",
                                                            symbol: asset?.value.wallet?.asset.symbol ?? "",
                                                            accuracy: asset?.value.wallet?.asset.accuracy.intValue ?? 0)
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
        return proceed
    }
    
    var textFields: [UITextField] {
        return [
            walletAddress,
            amount
        ]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return goToTextField(after: textField)
    }
    
}
