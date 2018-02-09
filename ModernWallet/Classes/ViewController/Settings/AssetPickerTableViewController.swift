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
    
    fileprivate var filter: ((SingleAssetViewModel) -> Bool)? = nil
    
    fileprivate let baseAssetsViewModel = BaseAssetsViewModel()
    
    fileprivate let assetPickSubject = PublishSubject<LWAssetModel>()
    
    fileprivate let rows = Variable([SingleAssetViewModel]())
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = Localize("settings.newDesign.baseAsset")

        tableView.backgroundView = BackgroundView(frame: tableView.bounds)
        
        rows.asObservable()
        .bind(to: tableView.rx.items(cellIdentifier: "PickAssetCell",
                                     cellType: AssetPickTableViewCell.self)) { [weak self] (row, element, cell) in
            cell.displayBaseAssetAsSelected = self?.displayBaseAssetAsSelected ?? false
            cell.setBaseAssetData(element)
        }.disposed(by: disposeBag)

        let rowSelected = tableView.rx
        .modelSelected(SingleAssetViewModel.self)
        .observeOn(MainScheduler.asyncInstance)
        
        rowSelected
        .subscribe(onNext: { [weak self] selected in
            if let indexPath = self?.tableView.indexPathForSelectedRow {
                self?.tableView.deselectRow(at: indexPath, animated: true)
            }
            
            self?.assetPickSubject.onNext(selected.asset.value)
        })
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
            .map({ [weak viewController] (assets) -> [SingleAssetViewModel] in
                if let filter = viewController?.filter {
                    return assets.filter(filter)
                } else {
                    return assets
                }
            }).drive(rows),
            loadingViewModel.isLoading.bind(to: viewController.rx.loading),
            errors.drive(viewController.rx.error)
        ]
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
        applyFilter { $0.swiftDeposit }
    }
    
    func showOnlyVisaDepositableAssets() {
        applyFilter { $0.visaDeposit  }
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

