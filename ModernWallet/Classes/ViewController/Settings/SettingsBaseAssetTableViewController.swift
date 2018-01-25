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
    
    struct RowInfo {
        let identity: String
        let title: String?
        let isCurrentBaseAsset: Bool?
    }
    
    var viewModel: SettingsViewModel!
    var baseAssetsViewModel = BaseAssetsViewModel()
    
    weak var delegate: SettingsBaseAssetDelegate?
    
    private let rows = Variable([RowInfo]())
    
    private let selectedRow = PublishSubject<RowInfo>()
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = Localize("settings.newDesign.baseAsset")

        tableView.backgroundView = BackgroundView(frame: tableView.bounds)
        
        bindObservers()
    }
    
    private func bindObservers() {
        
        // Handle error
        baseAssetsViewModel.result.asObservable()
            .filterError()
            .bind(to: rx.error)
            .disposed(by: disposeBag)
        
        // Handle success
        let fetchedBaseAssets = baseAssetsViewModel.result.asObservable()
            .filterSuccess()
            .shareReplay(1)

        Observable.combineLatest(fetchedBaseAssets, viewModel.appSettings.asObservable()) { (baseAssets: $0, currentBaseAsset: $1.baseAsset) }
            .map({ allAndCurrentAssets -> [RowInfo] in
                guard let allAssets = allAndCurrentAssets.baseAssets.assets as? [LWAssetModel] else { return [] }
                return allAssets
                    .filter { !$0.blockchainDepositEnabled } // dev note: this line can be commented in order to show all assets
                    .map { asset in
                        let isCurrentBaseAsset = asset.identity == allAndCurrentAssets.currentBaseAsset.identity
                        return RowInfo(identity: asset.identity, title: asset.displayId, isCurrentBaseAsset: isCurrentBaseAsset)
                }
            })
            .asDriver(onErrorJustReturn: [])
            .drive(rows)
            .disposed(by: disposeBag)

        rows.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "BaseAssetCell", cellType: SelectBaseAssetTableViewCell.self)) { (row, element, cell) in
                cell.setBaseAssetData(element)
            }.disposed(by: disposeBag)

        tableView.rx
            .modelSelected(RowInfo.self)
            .subscribe(onNext: { [weak self] rowInfo in
                self?.selectedRow.onNext(rowInfo)
                if let indexPath = self?.tableView.indexPathForSelectedRow {
                    self?.tableView.deselectRow(at: indexPath, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        // Update the base asset for the current user on the server
        let setBaseAssetRequest = selectedRow.asObserver()
            .map { $0.identity }
            .flatMap { assetId in
                LWRxAuthManager.instance.baseAssetSet.request(withParams: assetId)
            }
            .shareReplay(1)
        
        setBaseAssetRequest.filterError()
            .bind(to: rx.error)
            .disposed(by: disposeBag)
        
        setBaseAssetRequest.filterSuccess()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.delegate?.didUpdateBaseAsset()
                self.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
        
    }

}

extension SelectBaseAssetTableViewCell {
    typealias RowInfo = SettingsBaseAssetTableViewController.RowInfo
    
    func setBaseAssetData(_ rowInfo: RowInfo) {
        title = rowInfo.title
        isSelectedBaseAsset = rowInfo.isCurrentBaseAsset ?? false
    }
    
}

