//
//  SettingsBaseAssetTableViewController.swift
//  ModernMoney
//
//  Created by Lyubomir Marinov on 23.01.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

protocol SettingsBaseAssetDelegate: class {
    func didUpdateBaseAsset()
}

class SettingsBaseAssetTableViewController: UITableViewController {
    
    var viewModel: SettingsViewModel!
    var baseAssetsViewModel = BaseAssetsViewModel()
    
    weak var delegate: SettingsBaseAssetDelegate?
    
    fileprivate let rows = Variable([SingleAssetViewModel]())
    
    private let selectedRow = PublishSubject<SingleAssetViewModel>()
    
    fileprivate let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = Localize("settings.newDesign.baseAsset")

        tableView.backgroundView = BackgroundView(frame: tableView.bounds)
        
        rows.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "BaseAssetCell", cellType: SelectBaseAssetTableViewCell.self)) { (row, element, cell) in
                cell.setBaseAssetData(element)
            }.disposed(by: disposeBag)

        let rowSelected = tableView.rx
            .modelSelected(SingleAssetViewModel.self)
        
        rowSelected
            .subscribe(onNext: { [weak self] selection in
                self?.selectedRow.onNext(selection)
            })
            .disposed(by: disposeBag)
        
        rowSelected
            .subscribe(onNext: { [weak self] _ in
                if let indexPath = self?.tableView.indexPathForSelectedRow {
                    self?.tableView.deselectRow(at: indexPath, animated: true)
                }
            })
            .disposed(by: disposeBag)

        // Update the base asset for the current user on the server
        let setBaseAssetRequest = selectedRow.asObserver()
            .flatMap { asset in
                LWRxAuthManager.instance.baseAssetSet.request(withParams: asset.identity.value)
            }
            .shareReplay(1)

        setBaseAssetRequest.filterError()
            .bind(to: rx.error)
            .disposed(by: disposeBag)

        let setBaseAssetSuccess = setBaseAssetRequest.filterSuccess()
        setBaseAssetSuccess
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.delegate?.didUpdateBaseAsset()
            }).disposed(by: disposeBag)
        
        setBaseAssetSuccess
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
        
        // Bind the view models
        bindViewModels()
    }
}

fileprivate extension BaseAssetsViewModel {
    func bind(toRows rows: Variable<[SingleAssetViewModel]>, inViewController viewController: SettingsBaseAssetTableViewController) -> [Disposable] {
        return [
            assetsViewModel.assets.drive(rows),
            loadingViewModel.isLoading.bind(to: viewController.rx.loading),
            errors.drive(viewController.rx.error)
        ]
    }
}

extension SettingsBaseAssetTableViewController {
    func bindViewModels() {
        
        baseAssetsViewModel
            .bind(toRows: rows, inViewController: self)
            .disposed(by: disposeBag)
    }
}

extension SelectBaseAssetTableViewCell {
    func setBaseAssetData(_ assetInfo: SingleAssetViewModel) {
        assetInfo.title
            .drive(assetTitleLabel.rx.text)
            .disposed(by: disposeBag)

        assetInfo.isSelected.asDriver()
            .drive(onNext: { [weak self] in
                self?.isSelectedBaseAsset = $0
            })
            .disposed(by: disposeBag)
    }
    
}

