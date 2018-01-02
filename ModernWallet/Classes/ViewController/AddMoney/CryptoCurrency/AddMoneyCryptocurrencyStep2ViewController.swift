//
//  AddMoneyCryptocurrencyStep2ViewController.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 6/30/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Toast
import WalletCore

class AddMoneyCryptocurrencyStep2ViewController: UIViewController {

    //MARK:- Views
    @IBOutlet weak var copyButton: UITapGestureRecognizer!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var emailMeButton: UIButton!
    @IBOutlet weak var walletDescription: UILabel!
    @IBOutlet weak var copyLabel: UILabel!
    
    //MARK:- Services
    let walletsManager = LWRxPrivateWalletsManager.instance
    
    //MARK:- Data
    var wallet = Variable<LWPrivateWalletModel?>(nil)
    
    //MARK:- View Models
    lazy var copyWalletViewModel: CopyWalletAddressViewModel = {
        return CopyWalletAddressViewModel(
            tap: self.copyButton.rx.event.asDriver().map{_ in Void()},
            wallet: self.wallet
        )
    }()
    
    lazy var sendEmailWithAddressViewModel: SendEmailWithAddressViewModel = {
        return SendEmailWithAddressViewModel(
            sendObservable: self.emailMeButton.rx.tap.asObservable(),
            wallet: self.wallet
        )
    }()
    
    //MARK: Dispose Bag
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        title = Localize("wallets.private.address.pagetitle")
        
        localize()
        
        copyWalletViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        sendEmailWithAddressViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)

        handleQRCode()
        // Do any additional setup after loading the view from its nib.
    }
    
    //MARK:- QR Code
    func handleQRCode() {
        wallet
            .asObservable()
            .filterNil()
            .subscribe(onNext: {[weak self] in self?.addQRCodeImage(forWallet: $0)})
            .disposed(by: disposeBag)
    }
    
    func addQRCodeImage(forWallet wallet: LWPrivateWalletModel) {
        guard let address = wallet.address else { return }

        qrCodeImageView.image = UIImage.generateQRCode(
            fromString: address,
            withSize: qrCodeImageView.frame.size,
            color: UIColor.white
        )
    }
    
    func copy(walletAddress address: String) {
        UIPasteboard.general.string = address
        view.makeToast(Localize("wallets.bitcoin.copytoast"))
    }
    
    //MARK:- Localization
    func localize() {
        copyLabel.text = Localize("wallets.bitcoin.deposit.copy")
        emailMeButton.setTitle(Localize("wallets.bitcoin.deposit.sendemail"), for: .normal)
        walletDescription.text = Localize("addMoney.newDesign.walletBalanceDescription")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

fileprivate extension SendEmailWithAddressViewModel {
    func bind(toViewController vc: AddMoneyCryptocurrencyStep2ViewController) -> [Disposable] {
        return [
            emailSent.isLoading().asObservable()
                .bind(to: vc.rx.loading),
            
            emailSent.filterSuccess()
                .drive(onNext: {[weak vc] in
                    vc?.view.makeToast(Localize("wallets.bitcoin.sendemail"))
                })
        ]
    }
}

fileprivate extension CopyWalletAddressViewModel {
    func bind(toViewController vc: AddMoneyCryptocurrencyStep2ViewController) -> [Disposable] {
        return [
            tap.drive(onNext: {[weak vc] in vc?.copy(walletAddress: $0)})
        ]
    }
}
