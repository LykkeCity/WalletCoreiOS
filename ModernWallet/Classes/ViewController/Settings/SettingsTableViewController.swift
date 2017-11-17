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
    
    private let viewModel = SettingsViewModel()
    
    private let disposeBag = DisposeBag()
    
    private var rows = Variable([RowInfo]())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        navigationItem.title = Localize("settings.newDesign.title")

        let cellNib = UINib(nibName: "SettingsTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "SettingsCell")
        
        self.clearsSelectionOnViewWillAppear = true
        
        viewModel.appSettings.asObservable()
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
        
        tableView.rx
            .modelSelected(RowInfo.self)
            .subscribe(onNext: { [weak self] rowInfo in
                guard let `self` = self else { return }
                if rowInfo.segue != "" {
                    self.performSegue(withIdentifier: rowInfo.segue, sender: nil)
                }
                else if let indexPath = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
            })
            .disposed(by: disposeBag)

        viewModel.loadingViewModel.isLoading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PersonalData" {
            let vc = segue.destination as! SettingsPersonalDataTableViewController
            vc.viewModel = viewModel
        }
    }

}

extension Observable where Element == LWAppSettingsModel {
    
    func mapToSettingsRowInfo() -> Observable<[SettingsTableViewController.RowInfo]> {
        return map { (appSettings) in
            let confirmOrdersIcon = appSettings.shouldSignOrders ? #imageLiteral(resourceName: "CheckboxChecked") : #imageLiteral(resourceName: "CheckboxUnchecked")
            return [
                SettingsTableViewController.RowInfo(icon: #imageLiteral(resourceName: "PersonalDataIcon"), title: Localize("settings.newDesign.personalData"), segue: "PersonalData"),
                SettingsTableViewController.RowInfo(icon: confirmOrdersIcon, title: Localize("settings.newDesign.confirmOrders"), segue: ""),
                SettingsTableViewController.RowInfo(icon: #imageLiteral(resourceName: "BaseAssetIcon"), title: Localize("settings.newDesign.baseAsset"), subtitle: appSettings.baseAsset?.identity, subtitleFont: UIFont(name: "Geomanist", size: 15.0), segue: ""),
                SettingsTableViewController.RowInfo(icon: #imageLiteral(resourceName: "RefundIcon"), title: Localize("settings.newDesign.refundAddress"), subtitle: appSettings.refundAddress, segue: ""),
                SettingsTableViewController.RowInfo(icon: #imageLiteral(resourceName: "BackupPrivateKeyIcon"), title: Localize("settings.newDesign.backupPrivateKey"), segue: ""),
                SettingsTableViewController.RowInfo(icon: #imageLiteral(resourceName: "TermsIcon"), title: Localize("settings.newDesign.termsOfUse"), segue: "")
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

