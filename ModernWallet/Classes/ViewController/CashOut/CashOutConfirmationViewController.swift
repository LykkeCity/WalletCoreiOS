//
//  CashOutConfirmationViewController.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 29.10.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import WalletCore

class CashOutConfirmationViewController: UIViewController {
    
    typealias TitleDetailPair = (title: String?, detail: String?)
    
    @IBOutlet private weak var backgroundHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var confirmButton: UIButton!
    
    var cashOutViewModel: CashOutViewModel!
    
    fileprivate lazy var bankAccountDetails: [TitleDetailPair] = {
        let bankAccountViewModel = self.cashOutViewModel.bankAccountViewModel
        return [
            (title: Localize("cashOut.newDesign.accountName"), detail: bankAccountViewModel.accountName.valueOrNil),
            (title: Localize("cashOut.newDesign.iban"), detail: bankAccountViewModel.iban.valueOrNil),
            (title: Localize("cashOut.newDesign.bic"), detail: bankAccountViewModel.bic.valueOrNil),
            (title: Localize("cashOut.newDesign.accountHolder"), detail: bankAccountViewModel.accountHolder.valueOrNil),
            (title: Localize("cashOut.newDesign.currency"), detail: bankAccountViewModel.currency.valueOrNil)
        ].filter { $0.detail != nil }
    }()

    fileprivate lazy var generalDetails: [TitleDetailPair] = {
        let generalViewModel = self.cashOutViewModel.generalViewModel
        return [
            (title: Localize("cashOut.newDesign.name"), detail: generalViewModel.name.valueOrNil),
            (title: Localize("cashOut.newDesign.reaseon"), detail: generalViewModel.transactionReason.valueOrNil),
            (title: Localize("cashOut.newDesign.notes"), detail: generalViewModel.additionalNotes.valueOrNil)
        ].filter { $0.detail != nil }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        confirmButton.setTitle(Localize("newDesign.confirm"), for: .normal)
    }
    
    // MARK: - IBActions
    
    @IBAction private func confirmTapped() {
        
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

extension CashOutConfirmationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Cash Details, Bank Account Details, General
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // Number of asset to cash out from + Total
            return 2
        case 1:
            return bankAccountDetails.count
        case 2:
            return generalDetails.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return Localize("cashOut.newDesign.cashDetails")
        case 1:
            return Localize("cashOut.newDesign.bankAccountDetails")
        case 2:
            return Localize("cashOut.newDesign.general")
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        return cell
    }

}

extension CashOutConfirmationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header"),
            let label = headerView.contentView.subviews.last as? UILabel
        else {
            let headerView = UITableViewHeaderFooterView(reuseIdentifier: "Header")
            let label = UILabel()
            label.font = UIFont(name: "Geomanist-Light", size: 16.0)
            label.textAlignment = .center
            label.text = tableView.dataSource?.tableView?(tableView, titleForHeaderInSection: section)
            label.translatesAutoresizingMaskIntoConstraints = false
            headerView.contentView.addSubview(label)
            let views = ["label": label]
            headerView.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[label]-20-|", options: [], metrics: nil, views: views))
            headerView.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[label]-8-|", options: [], metrics: nil, views: views))
            return headerView
        }
        label.text = tableView.dataSource?.tableView?(tableView, titleForHeaderInSection: section)
        return headerView
    }
    
}

extension Variable where Element == String {
    
    var valueOrNil: String? {
        let value = self.value
        return value.isNotEmpty ? value : nil
    }
    
}
