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
    
    private let disposeBag = DisposeBag()
    
    private let refreshWallets = Variable<Void>(Void())
    
    private lazy var walletsViewModel: WalletsViewModel = {
        return WalletsViewModel(
            refreshWallets: self.refreshWallets.asObservable()
        )
    }()
    
    private lazy var kycNeededViewModel: KycNeededViewModel = {
        let selectedAsset = self.collectionView.rx.modelSelected(Variable<Asset>.self)
            .mapToApiResultObservable()

        return KycNeededViewModel(forAsset: selectedAsset)
    }()
    
    private lazy var loadingViewModel: LoadingViewModel = {
        return LoadingViewModel([
            self.walletsViewModel.loadingViewModel.isLoading.filter { !$0 }.startWith(true),
            self.kycNeededViewModel.loadingViewModel.isLoading
        ])
    }()
    
    private var assets = Variable<[Variable<Asset>]>([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        
        navigationItem.title = Localize("cashOut.newDesign.title")
        
        availableBalanceLabel.text = Localize("cashOut.newDesign.availableBalance")
        selectAssetLabel.text = Localize("cashOut.newDesign.selectAsset")

        walletsViewModel.totalBalance
            .drive(assetAmountView.rx.amount)
            .disposed(by: disposeBag)
        
        walletsViewModel.isEmpty
            .waitFor(loadingViewModel.isLoading)
            .drive(onNext: { [weak self] isEmpty in
                guard isEmpty, let `self` = self else { return }
                self.presentEmptyWallet(withMessage: Localize("emptyWallet.newDesign.cashOutMessage"))
            })
            .disposed(by: disposeBag)
        
            walletsViewModel.currencyName
            .drive(assetAmountView.rx.code)
            .disposed(by: disposeBag)
        
        collectionView.register(UINib(nibName: "AssetCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AssetCell")
        
        assets.asObservable()
            .bind(to: collectionView.rx.items(cellIdentifier: "AssetCell", cellType: AssetCollectionViewCell.self)) { (row, element, cell) in
                cell.bind(toAsset: AssetCollectionCellViewModel(element))
            }
            .disposed(by: disposeBag)
        
        walletsViewModel.wallets
            .filterOnlySwiftWithdraw()
            .map { wallets in wallets.sorted { $0.0.value.percent > $0.1.value.percent } }
            .bind(to: assets)
            .disposed(by: disposeBag)
        
        kycNeededViewModel.needToFillData
            .waitFor(loadingViewModel.isLoading)
            .map{UIStoryboard(name: "KYC", bundle: nil).instantiateViewController(withIdentifier: "kycTabNVC")}
            .subscribe(onNext: {[weak self] controller in
                self?.navigationController?.present(controller, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        kycNeededViewModel.pending
            .waitFor(loadingViewModel.isLoading)
            .map{UIStoryboard(name: "KYC", bundle: nil).instantiateViewController(withIdentifier: "kycPendingVC")}
            .subscribe(onNext: {[weak self] controller in
                self?.navigationController?.present(controller, animated: true)
            })
            .disposed(by: disposeBag)
        
        kycNeededViewModel.ok
            .waitFor(loadingViewModel.isLoading)
            .subscribe(onNext: { [weak self] in
                guard let `self` = self,
                    let indexPath = self.collectionView.indexPathsForSelectedItems?.first else { return }
                
                let selectedWallet = self.assets.asObservable()
                    .map{ assets in assets[indexPath.row].value.wallet }
                    .filterNil()
                
                self.performSegue(withIdentifier: "NextStep", sender: selectedWallet)
            })
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

fileprivate extension ObservableType where Self.E == Variable<Asset> {
    func mapToApiResultObservable() -> Observable<ApiResult<LWAssetModel>> {
        return map{ $0.value.wallet?.asset }
            .filterNil()
            .flatMap{
                Observable
                    .just(ApiResult.success(withData: $0))
                    .startWith(.loading)
            }
    }
}
