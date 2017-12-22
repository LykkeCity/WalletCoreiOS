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
    var copyWalletViewModel: CopyWalletAddressViewModel?
    var sendEmailWithAddressViewModel: SendEmailWithAddressViewModel?
    
    //MARK: Dispose Bag
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        title = Localize("wallets.private.address.pagetitle")
        
        localize()
        
        //loading private wallets and assign the first one to the current wallet
//        walletsManager.loadWallets()
//            .filterSuccess()
//            .map{$0.filter{$0.address == self.address}}
//            .map{$0.first}
//            .bind(to: wallet)
//            .disposed(by: disposeBag)
//    
        copyWalletViewModel = CopyWalletAddressViewModel(
            tap: copyButton.rx.event.asDriver().map{_ in Void()},
            wallet: self.wallet
        )
        
        sendEmailWithAddressViewModel = SendEmailWithAddressViewModel(sendObservable: emailMeButton.rx.tap.asObservable(), wallet: self.wallet)
        
//        #if TEST
//            qrCodeImageView.image = #imageLiteral(resourceName: "BetaQrCode")
//            copyButton.isEnabled = false
//            copyLabel.alpha = 0.6
//            emailMeButton.isEnabled = false
//        #else
            observeCopyWallet()
            observeEmailMeWalletAddress()
            handleQRCode()
//        #endif
        localize()
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
    
    //MARK:- Send Wallet Address
    func observeEmailMeWalletAddress() {
        //Loading indicator
        sendEmailWithAddressViewModel?.emailSent
            .isLoading()
            .asObservable()
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
        //Toast message
        sendEmailWithAddressViewModel?.emailSent
            .filterSuccess()
            .drive(onNext: {[weak self] in
                self?.view.makeToast(Localize("wallets.bitcoin.sendemail"))
            })
            .disposed(by: disposeBag)
    }
    
    //MARK:- Copy Wallet Address
    func observeCopyWallet() {
        copyWalletViewModel?.tap
            .drive(onNext: {[weak self] in self?.copy(walletAddress: $0)})
            .disposed(by: disposeBag)
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
