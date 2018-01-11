//
//  SelectCountryViewController.swift
//  ModernMoney
//
//  Created by Nacho Nachev  on 11.01.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import WalletCore

protocol SelectCountryViewControllerDelegate {
    
    func controller(_ controller: SelectCountryViewController, didSelectCountry country: LWCountryModel)
    
}

class SelectCountryViewController: UIViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    var viewModel: SelectCountryViewModel!
    
    var selectedCountry: LWCountryModel?
    
    var delegate: SelectCountryViewControllerDelegate?
    
    private let disposeBag = DisposeBag()
    
    fileprivate var isTransitioningSearchMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if viewModel == nil {
            viewModel = SelectCountryViewModel()
        }
        
        navigationItem.title = Localize("selectCountry,newDesign.title")

        searchController.delegate = self
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        searchController.searchBar.placeholder = Localize("selectCountry,newDesign.search")
        searchController.searchBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        }
        definesPresentationContext = true
        
        searchController.searchBar.rx.text
            .filterNil()
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
        
        viewModel.searchResult.asDriver()
            .drive(onNext: { [weak searchController, weak tableView](_) in
                if (searchController?.isActive ?? false) {
                    tableView?.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.sections.asDriver()
            .drive(onNext: { [weak searchController, weak tableView](_) in
                if (searchController?.isActive ?? true) {
                    tableView?.reloadData()
                }
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func closeTapped() {
        dismiss(animated: true)
    }

}

extension SelectCountryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isTransitioningSearchMode {
            return 0
        }
        if searchController.isActive {
            return 1
        }
        return viewModel.sections.value.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return viewModel.searchResult.value.count
        }
        return viewModel.sections.value[section].countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let country = self.country(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath) as! SelectCountryTableViewCell
        cell.name = country.name
        cell.isSelectedCountry = country.identity == selectedCountry?.identity
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive {
            return nil
        }
        return viewModel.sections.value[section].sectionName
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = self.country(at: indexPath)
        if let vc = self.presentedViewController {
            vc.dismiss(animated: true)
        }
        delegate?.controller(self, didSelectCountry: country)
    }
    
    fileprivate func country(at indexPath: IndexPath) -> LWCountryModel {
        let countries: [LWCountryModel]
        if searchController.isActive {
            countries = viewModel.searchResult.value
        }
        else {
            countries = viewModel.sections.value[indexPath.section].countries
        }
        return countries[indexPath.row]
    }
    
}

extension SelectCountryViewController: UISearchControllerDelegate {
    
    func willDismissSearchController(_ searchController: UISearchController) {
        isTransitioningSearchMode = true
        tableView.reloadData()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        isTransitioningSearchMode = false
        tableView.contentOffset = .zero
        tableView.reloadData()
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        isTransitioningSearchMode = true
        viewModel.searchText.value = searchController.searchBar.text ?? ""
        tableView.reloadData()
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        isTransitioningSearchMode = false
        tableView.contentOffset = .zero
        tableView.reloadData()
    }
    
}
