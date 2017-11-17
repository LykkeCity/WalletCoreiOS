//
//  SettingsPersonalDataTableViewController.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 17.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class SettingsPersonalDataTableViewController: UITableViewController {
    
    struct RowInfo {
        let icon: UIImage
        let name: String?
        let value: String?
    }
    
    var viewModel: SettingsViewModel!
    
    private let rows = Variable([RowInfo]())
    
    private let disposeBag = DisposeBag()
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        let imageView = UIImageView(image: #imageLiteral(resourceName: "BlueBackground"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        let views = ["imageView": imageView]
        let metrics = ["height": Display.height]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[imageView(height)]|", options: [], metrics: metrics, views: views))
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = Localize("settings.newDesign.personalData")
        
        let cellNib = UINib(nibName: "SettingsTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "SettingsCell")
        tableView.backgroundView = backgroundView
        
        viewModel.personalData.asObservable()
            .mapToSettingsRowInfo()
            .do(onNext: { [tableView] (rows) in
                let topInset = (Display.height - CGFloat(rows.count) * 80.0 - 120.0) / 2.0
                let insets = UIEdgeInsets(top: max(topInset, 0.0), left: 0, bottom: 0, right: 0)
                tableView?.contentInset = insets
            })
            .asDriver(onErrorJustReturn: [])
            .drive(rows)
            .disposed(by: disposeBag)
        
        rows.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "SettingsCell", cellType: SettingsTableViewCell.self)) { (row, element, cell) in
                cell.setPersonalData(element)
            }
            .disposed(by: disposeBag)
    }

}

extension Observable where Element == LWPersonalDataModel {
    
    func mapToSettingsRowInfo() -> Observable<[SettingsPersonalDataTableViewController.RowInfo]> {
        return map { (personalData) in
            var rowsData = [SettingsPersonalDataTableViewController.RowInfo]()
            rowsData.append(SettingsPersonalDataTableViewController.RowInfo(icon: #imageLiteral(resourceName: "NameIcon"), name: Localize("personalData.newDesign.fullName"), value: personalData.fullName))
            rowsData.append(SettingsPersonalDataTableViewController.RowInfo(icon: #imageLiteral(resourceName: "EmailIcon"), name: Localize("personalData.newDesign.email"), value: personalData.email))
            if !personalData.isPhoneEmpty() {
                rowsData.append(SettingsPersonalDataTableViewController.RowInfo(icon: #imageLiteral(resourceName: "PhoneIcon"), name: Localize("personalData.newDesign.phone"), value: personalData.phone))
            }
            let city = personalData.city ?? ""
            let address = personalData.country != nil ? "\(personalData.country!), \(city)" : city
            rowsData.append(SettingsPersonalDataTableViewController.RowInfo(icon: #imageLiteral(resourceName: "LocationIcon"), name: Localize("personalData.newDesign.countryAndCity"), value: address))
            return rowsData
        }
    }
    
}

extension SettingsTableViewCell {
    
    func setPersonalData(_ rowInfo: SettingsPersonalDataTableViewController.RowInfo) {
        separator.isHidden = true
        titleLabel.font = UIFont(name: "Geomanist-Light", size: 15.0)
        subtitleLabel.font = UIFont(name: "Geomanist-Light", size: 12.0)
        iconView.image = rowInfo.icon
        titleLabel.text = rowInfo.value
        subtitleLabel.text = rowInfo.name
    }
    
}
