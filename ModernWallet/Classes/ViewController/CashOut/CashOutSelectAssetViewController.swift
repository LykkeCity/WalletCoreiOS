//
//  CashOutSelectAssetViewController.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 10.10.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class CashOutSelectAssetViewController: UIViewController {
    
    @IBOutlet private var availableBalanceLabel: UILabel!
    
    @IBOutlet private var assetAmountView: AssetAmountView!
    
    @IBOutlet private var selectAssetLabel: UILabel!
    
    @IBOutlet private var collectionView: UICollectionView!
    
    private let totalBalanceViewModel = TotalBalanceViewModel(refresh: ReloadTrigger.instance.trigger(interval: 10))
    private let disposeBag = DisposeBag()
    
    private let refreshWallets = Variable<Void>(Void())
    
    private lazy var walletsViewModel: WalletsViewModel = {
        return WalletsViewModel(
            refreshWallets: self.refreshWallets.asObservable(),
            mainInfo: self.totalBalanceViewModel.observables.mainInfo.filterSuccess()
        )
    }()
    
    private lazy var loadingViewModel: LoadingViewModel = {
        return LoadingViewModel([
            self.walletsViewModel.loadingViewModel.isLoading.filter { !$0 }.startWith(true),
            self.totalBalanceViewModel.loading.isLoading
        ])
    }()
    
    private var assets = Variable<[Variable<Asset>]>([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        
        navigationItem.title = Localize("cashOut.newDesign.title")
        
        availableBalanceLabel.text = Localize("cashOut.newDesign.availableBalance")
        selectAssetLabel.text = Localize("cashOut.newDesign.selectAsset")

        totalBalanceViewModel.balance
            .drive(assetAmountView.rx.amount)
            .disposed(by: disposeBag)
        
        totalBalanceViewModel.isEmpty
            .drive(onNext: { [weak self] isEmpty in
                guard isEmpty, let `self` = self else { return }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let emptyWalletVC = storyboard.instantiateViewController(withIdentifier: "EmptyWallet") as! EmptyWalletViewController
                emptyWalletVC.message = Localize("emptyWallet.newDesign.cashOutMessage")
                self.rx.loading.onNext(false)
                self.navigationController?.setViewControllers([emptyWalletVC], animated: false)
            })
            .disposed(by: disposeBag)
        
        totalBalanceViewModel.currencyName
            .drive(assetAmountView.rx.code)
            .disposed(by: disposeBag)
        
        collectionView.register(UINib(nibName: "AssetCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AssetCell")
        
        assets.asObservable()
            .bind(to: collectionView.rx.items(cellIdentifier: "AssetCell", cellType: AssetCollectionViewCell.self)) { (row, element, cell) in
                cell.bind(toAsset: AssetCollectionCellViewModel(element))
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let `self` = self else { return }
                
                let selectedWallet = self.assets.asObservable()
                    .map{ assets in assets[indexPath.row].value.wallet }
                    .filterNil()
                
                self.performSegue(withIdentifier: "NextStep", sender: selectedWallet)
            })
            .disposed(by: disposeBag)
        
        walletsViewModel.wallets
            .filterOnlySwiftWithdraw()
            .map { wallets in wallets.sorted { $0.0.value.percent > $0.1.value.percent } }
            .bind(to: assets)
            .disposed(by: disposeBag)
        
        loadingViewModel.isLoading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
    }
    
    override func viewWillLayoutSubviews() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        let sideInset = view.frame.width.truncatingRemainder(dividingBy: layout.itemSize.width) / 2
        var insets = layout.sectionInset
        insets.left = sideInset
        insets.right = sideInset
        layout.sectionInset = insets
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NextStep" {
            
            guard
                let enterAmountVC = segue.destination as? CashOutEnterAmountViewController,
                let walletObservable = sender as? Observable<LWSpotWallet>
            else {
                return
            }
            
            enterAmountVC.walletObservable = walletObservable
        }
    }

}

fileprivate extension ObservableType where Self.E == [Variable<Asset>] {
    func filterOnlySwiftWithdraw() -> Observable<[Variable<Asset>]> {
        return map{wallets in
            wallets.filter{(asset: Variable<Asset>) in
                asset.value.wallet?.asset.swiftWithdraw ?? false
            }
        }
    }
}
