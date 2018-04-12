//
//  SettingsTableViewController.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 14.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class SettingsTableViewController: UITableViewController {
    
    struct RowInfo {
        
        let icon: UIImage
        let title: String?
        let subtitle: String?
        let subtitleFont: UIFont?
        let segue: String
        
        init(icon: UIImage, title: String?, subtitle: String? = nil, subtitleFont: UIFont? = nil, segue: String) {
            self.icon = icon
            self.title = title
            self.subtitle = subtitle
            self.subtitleFont = subtitleFont
            self.segue = segue
        }
        
    }
    
    fileprivate var viewModel = SettingsViewModel()
    
    fileprivate let disposeBag = DisposeBag()
    
    private var rows = Variable([RowInfo]())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        navigationItem.title = Localize("settings.newDesign.title")
        
        let cellNib = UINib(nibName: "SettingsTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "SettingsCell")
        
        self.clearsSelectionOnViewWillAppear = true
        
        Observable.combineLatest(viewModel.appSettings.asObservable(), viewModel.shouldSignOrder.asObservable())
            .mapToSettingsRowInfo()
            .asDriver(onErrorJustReturn: [
                RowInfo(icon: #imageLiteral(resourceName: "PersonalDataIcon"), title: Localize("settings.newDesign.personalData"), segue: ""),
                RowInfo(icon: #imageLiteral(resourceName: "CheckboxUnchecked"), title: Localize("settings.newDesign.confirmOrders"), segue: ""),
                RowInfo(icon: #imageLiteral(resourceName: "BaseAssetIcon"), title: Localize("settings.newDesign.baseAsset"), subtitle: "", subtitleFont: UIFont(name: "Geomanist", size: 15.0), segue: ""),
                RowInfo(icon: #imageLiteral(resourceName: "RefundIcon"), title: Localize("settings.newDesign.refundAddress"), subtitle: "", segue: ""),
                RowInfo(icon: #imageLiteral(resourceName: "BackupPrivateKeyIcon"), title: Localize("settings.newDesign.backupPrivateKey"), segue: ""),
                RowInfo(icon: #imageLiteral(resourceName: "TermsIcon"), title: Localize("settings.newDesign.termsOfUse"), segue: "")
                ])
            .drive(rows)
            .disposed(by: disposeBag)
        
        rows.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "SettingsCell", cellType: SettingsTableViewCell.self)) { (row, element, cell) in
                cell.setData(element)
            }
            .disposed(by: disposeBag)
        
        let modelSelected = tableView.rx.modelSelected(RowInfo.self).observeOn(MainScheduler.asyncInstance)
        
        modelSelected
            .bindToSignOrder(toViewModel: viewModel, context: self)
            .disposed(by: disposeBag)
        
        modelSelected
            .bindToPerformSeque(context: self)
            .disposed(by: disposeBag)
        
        viewModel.loadingViewModel.isLoading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueID = segue.identifier else { return }
        switch segueID {
        case "PersonalData":
            let vc = segue.destination as! SettingsPersonalDataTableViewController
            vc.viewModel = viewModel
            
        case "BaseAssetSelection":
            let vc = segue.destination as! AssetPickerTableViewController
            bindAssetPickerForBaseCurrencyChange(vc)
        default:
            break
        }
    }
}

extension SettingsTableViewController {
    
    func bindAssetPickerForBaseCurrencyChange(_ vc: AssetPickerTableViewController) {
        
        vc.displayBaseAssetAsSelected = true
        
        let setBaseAsset = vc.assetPicked.flatMap { picked in
            LWRxAuthManager.instance.baseAssetSet.request(withParams: picked.identity)
        }.shareReplay(1)
        
        setBaseAsset.filterError()
        .bind(to: rx.error)
        .disposed(by: disposeBag)
        
        setBaseAsset.filterSuccess()
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self, weak vc] _ in
            self?.viewModel.performRefreshSettings()
            vc?.dismissViewController()
        })
        .disposed(by: disposeBag)
    }
}

fileprivate extension ObservableType where Self.E == SettingsTableViewController.RowInfo {
    
    /// Bind to SettingsViewModel.shouldSignOrder. Each event will open pin view controller and if passed will change SettingsViewModel.shouldSignOrder with the opposite value.
    ///
    /// - Parameters:
    ///   - viewModel: ViewModel that shouldSignOrder will be changed
    ///   - vc: Context where it's called the binding
    /// - Returns: Diposable of the binding
    func bindToSignOrder(toViewModel viewModel: SettingsViewModel, context vc: UIViewController) -> Disposable {
        return
            filter{ $0.title == Localize("settings.newDesign.confirmOrders") }
            .flatMap{ [weak vc] _ -> Observable<Bool> in
                guard let vc = vc else { return Observable<Bool>.never() }
                return PinViewController.presentPinViewControllerWithCompleted(from: vc, title: Localize("newDesign.enterPin"), isTouchIdEnabled: false)
            }
            .filter{ $0 }
            .map{ _ in !viewModel.shouldSignOrder.value }
            .bind(to: viewModel.shouldSignOrder)
    }
    
    /// Bind RowInfo to performing segue.If RowInfo does not contains segue the cell will be deselected
    ///
    /// - Parameter vc: Context where it's called the binding
    /// - Returns: Disposable of the binding
    func bindToPerformSeque(context vc: UITableViewController) -> Disposable {
        return subscribe(onNext: { [weak vc] rowInfo in
            guard let vc = vc else { return }
            
            if rowInfo.segue != "" {
                vc.performSegue(withIdentifier: rowInfo.segue, sender: nil)
            }
            else if let indexPath = vc.tableView.indexPathForSelectedRow {
                vc.tableView.deselectRow(at: indexPath, animated: true)
                if rowInfo.title == Localize("settings.newDesign.refundAddress") {
                    UIPasteboard.general.string = rowInfo.subtitle
                    vc.view.makeToast(Localize("receive.newDesign.copyToast"))
                }
            }
        })
    }
}

fileprivate extension ObservableType where Self.E == (LWAppSettingsModel, Bool) {
    func mapToSettingsRowInfo() -> Observable<[SettingsTableViewController.RowInfo]> {
        return map { appSettings, shouldSignOrders in
            let confirmOrdersIcon = shouldSignOrders ? #imageLiteral(resourceName: "CheckboxChecked") : #imageLiteral(resourceName: "CheckboxUnchecked")
            return [
                SettingsTableViewController.RowInfo(icon: #imageLiteral(resourceName: "PersonalDataIcon"), title: Localize("settings.newDesign.personalData"), segue: "PersonalData"),
                SettingsTableViewController.RowInfo(icon: confirmOrdersIcon, title: Localize("settings.newDesign.confirmOrders"), segue: ""),
                SettingsTableViewController.RowInfo(icon: #imageLiteral(resourceName: "BaseAssetIcon"), title: Localize("settings.newDesign.baseAsset"), subtitle: appSettings.baseAsset?.displayId ?? appSettings.baseAsset?.name, subtitleFont: UIFont(name: "Geomanist", size: 15.0), segue: "BaseAssetSelection"),
                SettingsTableViewController.RowInfo(icon: #imageLiteral(resourceName: "RefundIcon"), title: Localize("settings.newDesign.refundAddress"), subtitle: appSettings.refundAddress, segue: ""),
                SettingsTableViewController.RowInfo(icon: #imageLiteral(resourceName: "BackupPrivateKeyIcon"), title: Localize("settings.newDesign.backupPrivateKey"), segue: "BackupKey"),
                SettingsTableViewController.RowInfo(icon: #imageLiteral(resourceName: "TermsIcon"), title: Localize("settings.newDesign.termsOfUse"), segue: "TermsOfUse")
            ]
        }
    }
}

extension SettingsTableViewCell {
    
    func setData(_ rowInfo: SettingsTableViewController.RowInfo) {
        iconView.image = rowInfo.icon
        titleLabel.text = rowInfo.title
        if let subtitle = rowInfo.subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.font = rowInfo.subtitleFont ?? UIFont(name: "Geomanist-Light", size: 15.0)
            subtitleLabel.isHidden = false
        }
        else {
            subtitleLabel.isHidden = true
        }
    }
    
}

