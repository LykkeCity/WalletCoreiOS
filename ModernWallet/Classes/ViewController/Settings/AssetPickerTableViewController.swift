//
//  AssetPickerTableViewController.swift
//  ModernMoney
//
//  Created by Lyubomir Marinov on 23.01.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class AssetPickerTableViewController: UITableViewController {
    
    var assetPicked: Observable<LWAssetModel> {
        return assetPickSubject.asObservable()
    }
    
    var displayBaseAssetAsSelected = false
    
    typealias Filter = ((SingleAssetViewModel) -> Bool)
    
    fileprivate var filter: Filter? = nil
    
    fileprivate let baseAssetsViewModel = BaseAssetsViewModel()
    
    fileprivate let assetPickSubject = PublishSubject<LWAssetModel>()
    
    fileprivate let rows = Variable([SingleAssetViewModel]())
    
    let disposeBag = DisposeBag()
    
    var loadingViewModel: LoadingViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = Localize("settings.newDesign.baseAsset")

        tableView.backgroundView = BackgroundView(frame: tableView.bounds)
        
        rows.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "PickAssetCell",
                                         cellType: AssetPickTableViewCell.self)) { [weak self] (row, element, cell) in
                cell.displayBaseAssetAsSelected = self?.displayBaseAssetAsSelected ?? false
                cell.setBaseAssetData(element)
            }
            .disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(SingleAssetViewModel.self)
            .observeOn(MainScheduler.asyncInstance)
            .do(onNext: { [weak tableView] _ in
                if let indexPath = tableView?.indexPathForSelectedRow {
                    tableView?.deselectRow(at: indexPath, animated: true)
                }
            })
            .map{ $0.asset.value }
            .bind(to: assetPickSubject)
            .disposed(by: disposeBag)
        
        bindViewModels()
    }
    
    func applyFilter(_ filter: @escaping ((LWAssetModel) -> Bool)) {
        self.filter = { (singleAssetVM: SingleAssetViewModel) -> Bool in
            return filter(singleAssetVM.asset.value)
        }
    }
}

fileprivate extension BaseAssetsViewModel {
    func bind(toRows rows: Variable<[SingleAssetViewModel]>, inViewController viewController: AssetPickerTableViewController) -> [Disposable] {
        return [
            assetsViewModel.assets
                .filterAssets(by: viewController.filter)
                .drive(rows),
            loadingViewModel.isLoading.bind(to: viewController.rx.loading),
            errors.drive(viewController.rx.error)
        ]
    }
}

fileprivate extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, Self.E == [SingleAssetViewModel] {
    
    /// Filter assets by the given filter
    ///
    /// - Parameter filter: Filter that is used for filtering assets
    /// - Returns: Observable of filtered assets
    func filterAssets(by filter: AssetPickerTableViewController.Filter?) -> Driver<[SingleAssetViewModel]> {
        return map({ assets -> [SingleAssetViewModel] in
            
            guard let filter = filter else {
                return assets
            }
            
            return assets.filter(filter)
        })
    }
}

extension AssetPickerTableViewController {
    
    static func instantiateViewController() -> AssetPickerTableViewController {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "assetPickerViewController")
        return vc as! AssetPickerTableViewController
    }
    
    func bindViewModels() {
        baseAssetsViewModel
            .bind(toRows: rows, inViewController: self)
            .disposed(by: disposeBag)
    }
    
    func dismissViewController(_ animated: Bool = true) {
        if let navigationVc = self.navigationController {
            navigationVc.popViewController(animated: animated)
        } else {
            dismiss(animated: animated, completion: nil)
        }
    }
    
    func showOnlyAssetsWithSwiftTransfer() {
        applyFilter { $0.swiftDeposit && $0.isFiat }
    }
    
    func showOnlyVisaDepositableAssets() {
        applyFilter { $0.visaDeposit && $0.isFiat }
    }
}

extension AssetPickTableViewCell {
    func setBaseAssetData(_ assetInfo: SingleAssetViewModel) {
        assetInfo.title
            .drive(assetTitleLabel.rx.text)
            .disposed(by: disposeBag)
        
        assetInfo.isSelected.asObservable()
        .filter { [weak self] _ in
            return self?.displayBaseAssetAsSelected ?? false
        }.asDriver(onErrorJustReturn: false)
        .drive(onNext: { [weak self] in
            self?.isSelectedBaseAsset = $0
        })
        .disposed(by: disposeBag)
    }
}

