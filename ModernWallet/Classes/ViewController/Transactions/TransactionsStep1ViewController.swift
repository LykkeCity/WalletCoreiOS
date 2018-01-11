//
//  TransactionsStep1ViewController.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 7/11/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import WalletCore

class TransactionsStep1ViewController: UIViewController {

    @IBOutlet weak var tableHeader: UIView!
    @IBOutlet weak var sortIcon: UIImageView!
    @IBOutlet weak var findTransactionBtn: UIButton!
    @IBOutlet weak var filterTransactionBtn: UIButton!
    @IBOutlet weak var downloadCSV: UIButton!
    @IBOutlet weak var transactionsTableView: UITableView!
    @IBOutlet weak var findTransactionLbl: UILabel!
    @IBOutlet weak var filterTransactionLbl: UILabel!
    @IBOutlet weak var downloadCSVLbl: UILabel!
    
    var isTableHeaderHidden = false
    var shouldAddBackgroundImage = false
    
    lazy var transactionsViewModel:TransactionsViewModel = {
        return TransactionsViewModel(
            downloadCsv: self.downloadCSV.rx.tap.asObservable(),
            currencyExchanger: CurrencyExchanger()
        )
    }()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        
        if shouldAddBackgroundImage {
            view.insertSubview(UIImageView(image: #imageLiteral(resourceName: "Background")), belowSubview: transactionsTableView)
        }
        
        tableHeader.isHidden = isTableHeaderHidden
        
        localize()
        
        transactionsTableView.register(UINib(nibName: "PortfolioCurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: "PortfolioCurrencyTableViewCell")
        
        filterTransactionBtn.rx.tap.asObservable()
            .map{[transactionsViewModel] in transactionsViewModel.sortBy.value.reversed }
            .bind(to: transactionsViewModel.sortBy)
            .disposed(by: disposeBag)
        
        transactionsViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func creatCSV(_ path: URL) -> Void {
        let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
    
    private func localize() {
        findTransactionLbl.text = Localize("transaction.newDesign.findTransaction")
        filterTransactionLbl.text = Localize("transaction.newDesign.sortTransaction")
        downloadCSVLbl.text = Localize("transaction.newDesign.downoloadCSV")
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

extension TransactionsStep1ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        
        transactionsViewModel.filter.value = text
    }
    
    
    static func factorySearchContainer(withViewModel viewModel: TransactionsViewModel? = nil) -> UISearchContainerViewController {
        let storyboard = UIStoryboard(name: "Transactions", bundle: nil)
        
        guard let searchResultsController = storyboard.instantiateViewController(withIdentifier: "transactionsVC")
            as? TransactionsStep1ViewController else {
                fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
        }
        
        if let viewModel = viewModel {
            searchResultsController.transactionsViewModel = viewModel
        }
        
        searchResultsController.isTableHeaderHidden = true
        searchResultsController.shouldAddBackgroundImage = true
        
        let searchController = UISearchController(searchResultsController: searchResultsController)
        let searchContainer = UISearchContainerViewController(searchController: searchController)
        
        searchController.searchResultsUpdater = searchResultsController
        searchController.searchBar.placeholder = "Search transactions"
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.barTintColor = Colors.darkGreen
        searchController.searchBar.sizeToFit()
        
        return searchContainer
    }
}

fileprivate extension TransactionsViewModel {
    func bind(toViewController vc: TransactionsStep1ViewController) -> [Disposable] {
        return [
            transactions.asObservable()
                .bind(to: vc.transactionsTableView.rx.items(cellIdentifier: "PortfolioCurrencyTableViewCell",
                                                            cellType: PortfolioCurrencyTableViewCell.self)
                ){ (row, element, cell) in cell.bind(toTransaction: element) },
            
            loading.isLoading
                .bind(to: vc.rx.loading),
            
            transactionsAsCsv
                .filterSuccess()
                .drive(onNext: {[weak vc] path in vc?.creatCSV(path)}),
            
            sortBy.asDriver()
                .map{ $0.asImage() }
                .drive(vc.sortIcon.rx.image)
        ]
    }
}

fileprivate extension TransactionsViewModel.SortType {
    func asImage() -> UIImage {
        switch self {
        case .asc: return #imageLiteral(resourceName: "sortAscending")
        case .desc: return #imageLiteral(resourceName: "sortDescending")
        }
    }
}
