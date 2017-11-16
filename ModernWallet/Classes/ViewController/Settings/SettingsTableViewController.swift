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
    
    struct RowData {
        
        let icon: Variable<UIImage>
        let title: String?
        let subtitle: Variable<String>?
        let subtitleFont: UIFont?
        let segue: String
        
        init(icon: UIImage, title: String?, subtitle: Variable<String>? = nil, subtitleFont: UIFont? = nil, segue: String) {
            self.icon = Variable(icon)
            self.title = title
            self.subtitle = subtitle
            self.subtitleFont = subtitleFont
            self.segue = segue
        }

        init(icon: Variable<UIImage>, title: String?, subtitle: Variable<String>? = nil, subtitleFont: UIFont? = nil, segue: String) {
            self.icon = icon
            self.title = title
            self.subtitle = subtitle
            self.subtitleFont = subtitleFont
            self.segue = segue
        }

    }
    
    private let viewModel = SettingsViewModel()
    
    private let disposeBag = DisposeBag()
    
    private lazy var rows: [RowData] = {
        let shouldSignOrdersIcon = Variable(#imageLiteral(resourceName: "CheckboxUnchecked"))
        self.viewModel.shouldSignOrders
            .driveCheckboxImage(shouldSignOrdersIcon)
            .disposed(by: self.disposeBag)
        return [
            RowData(icon: #imageLiteral(resourceName: "PersonalDataIcon"), title: Localize("settings.newDesign.personalData"), segue: ""),
            RowData(icon: shouldSignOrdersIcon, title: Localize("settings.newDesign.confirmOrders"), segue: ""),
            RowData(icon: #imageLiteral(resourceName: "BaseAssetIcon"), title: Localize("settings.newDesign.baseAsset"), subtitle: self.viewModel.baseAsset, subtitleFont: UIFont(name: "Geomanist", size: 15.0), segue: ""),
            RowData(icon: #imageLiteral(resourceName: "RefundIcon"), title: Localize("settings.newDesign.refundAddress"), subtitle: self.viewModel.refundAddress, segue: ""),
            RowData(icon: #imageLiteral(resourceName: "BackupPrivateKeyIcon"), title: Localize("settings.newDesign.backupPrivateKey"), segue: ""),
            RowData(icon: #imageLiteral(resourceName: "TermsIcon"), title: Localize("settings.newDesign.termsOfUse"), segue: "")
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        navigationItem.title = Localize("settings.newDesign.title")

        self.clearsSelectionOnViewWillAppear = false

        viewModel.loadingViewModel.isLoading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsTableViewCell

        let rowData = rows[indexPath.row]
        cell.set(title: rowData.title, icon: rowData.icon, subtitle: rowData.subtitle)
        if rowData.subtitle != nil {
            cell.subtitleLabel.font = rowData.subtitleFont ?? UIFont(name: "Geomanist-Light", size: 15.0)
        }

        return cell
    }
    
    // MARK: // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowData = rows[indexPath.row]
        if rowData.segue != "" {
            performSegue(withIdentifier: rowData.segue, sender: nil)
        }
        else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension Variable where Element == Bool {
    
    func driveCheckboxImage(_ variable: Variable<UIImage>) -> Disposable {
        return self.asObservable()
            .map { $0 ? #imageLiteral(resourceName: "CheckboxChecked") : #imageLiteral(resourceName: "CheckboxUnchecked") }
            .asDriver(onErrorJustReturn: #imageLiteral(resourceName: "CheckboxUnchecked"))
            .drive(variable)
    }
    
}
