//
//  CashOutConfirmationViewController.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 29.10.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class CashOutConfirmationViewController: UIViewController {
    
    typealias TitleDetailPair = (title: String?, detail: String?)
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var confirmButton: UIButton!
    
    var cashOutViewModel: CashOutViewModel!
    
    private let disposeBag = DisposeBag()
    
    fileprivate lazy var bankAccountDetails: [TitleDetailPair] = {
        let bankAccountViewModel = self.cashOutViewModel.bankAccountViewModel
        return [
            (title: Localize("cashOut.newDesign.bankName"), detail: bankAccountViewModel.bankName.valueOrNil),
            (title: Localize("cashOut.newDesign.iban"), detail: bankAccountViewModel.iban.valueOrNil),
            (title: Localize("cashOut.newDesign.bic"), detail: bankAccountViewModel.bic.valueOrNil),
            (title: Localize("cashOut.newDesign.accHolder"), detail: bankAccountViewModel.accountHolder.valueOrNil),
            (title: Localize("cashOut.newDesign.accHolderAddress"), detail: bankAccountViewModel.accountHolderAddress.valueOrNil),
            (title: Localize("cashOut.newDesign.accHolderCountry"), detail: bankAccountViewModel.accountHolderCountry.valueOrNil),
            (title: Localize("cashOut.newDesign.accHolderCountryCode"), detail: bankAccountViewModel.accountHolderCountryCode.valueOrNil),
            (title: Localize("cashOut.newDesign.accHolderZipCode"), detail: bankAccountViewModel.accountHolderZipCode.valueOrNil),
            (title: Localize("cashOut.newDesign.accHolderCity"), detail: bankAccountViewModel.accountHolderCity.valueOrNil)
        ].filter { $0.detail != nil }
    }()

    fileprivate lazy var generalDetails: [TitleDetailPair] = {
        let generalViewModel = self.cashOutViewModel.generalViewModel
        return [
            (title: Localize("cashOut.newDesign.name"), detail: generalViewModel.name.valueOrNil),
            (title: Localize("cashOut.newDesign.transactionReason"), detail: generalViewModel.transactionReason.valueOrNil),
            (title: Localize("cashOut.newDesign.additionalNotes"), detail: generalViewModel.additionalNotes.valueOrNil)
        ].filter { $0.detail != nil }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        confirmButton.setTitle(Localize("newDesign.confirm"), for: .normal)
        
        confirmButton.rx.tap
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let strongSelf = self else { return Observable<Void>.never() }
                return PinViewController.presentOrderPinViewController(from: strongSelf, title: Localize("newDesign.enterPin"), isTouchIdEnabled: true)
            }
            .bind(to: cashOutViewModel.trigger)
            .disposed(by: disposeBag)
        
        cashOutViewModel.errors.asObservable()
            .bind(to: rx.error)
            .disposed(by: disposeBag)
        
        cashOutViewModel.success
            .waitFor(cashOutViewModel.loadingViewModel.isLoading)
            .drive(onNext: { [weak self] result in
                FinalizePendingRequestsTrigger.instance.finalizeNow()
                self?.performSegue(withIdentifier: "ShowSummary", sender: result)
            })
            .disposed(by: disposeBag)
        
        cashOutViewModel.loadingViewModel.isLoading
            .asDriver(onErrorJustReturn: false)
            .drive(rx.loading)
            .disposed(by: disposeBag)
        
        tableView.reloadData()
    }
    
    // MARK: - IBActions
    
    @IBAction func unwindToConfirmationViewController(segue:UIStoryboardSegue) { }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSummary" {
            guard
                let vc = segue.destination as? CashOutSummaryViewController,
                let result = sender as? LWModelCashOutSwiftResult
            else { return }
            vc.result = result
        }
    }
    
    // MARK: - Private
    
    fileprivate func titleDetailPairForRow(at indexPath: IndexPath) -> TitleDetailPair? {
        switch indexPath.section {
        case 1:
            return bankAccountDetails[indexPath.row - 1]
        case 2:
            return generalDetails[indexPath.row - 1]
        default:
            return nil
        }
    }

}

extension CashOutConfirmationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Cash Details, Bank Account Details, General
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // Header + Number of asset to cash out from + Total
            return 1 + 2
        case 1:
            return bankAccountDetails.count + 1
        case 2:
            return generalDetails.count + 1
        default:
            return 0
        }
    }
    
    func titleForHeaderInSection(_ section: Int) -> String? {
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
        if indexPath.row == 0 {
            return self.tableView(tableView, sectionHeaderCellForRowAt: indexPath)
        }
        if indexPath.section == 0 {
            return self.tableView(tableView, cashSectionCellForRowAt: indexPath)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! CashOutConfirmationDetailTableViewCell
        if let pair = titleDetailPairForRow(at: indexPath) {
            cell.nameLabel.text = pair.title
            cell.detailsLabel.text = pair.detail
        }
        return cell
    }
    
    private func tableView(_ tableView: UITableView, sectionHeaderCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SectionHeaderCell", for: indexPath) as! CashOutSectionHeaderTableViewCell
        cell.titleLabel.text = titleForHeaderInSection(indexPath.section)
        return cell
    }
    
    private func tableView(_ tableView: UITableView, cashSectionCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row <= 1 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TotalCell", for: indexPath) as! CashOutTotalTableViewCell
            cell.bind(to: cashOutViewModel.totalObservable)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssetCell", for: indexPath) as! CashOutAssetDetailsTableViewCell
        cell.bind(to: cashOutViewModel)
        return cell
    }
    
}

extension Variable where Element == String {
    
    var valueOrNil: String? {
        let value = self.value
        return value.isNotEmpty ? value : nil
    }
    
}
