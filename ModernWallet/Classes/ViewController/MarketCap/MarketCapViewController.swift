//
//  MarketCapTableViewController.swift
//  ModernMoney
//
//  Created by Vasil Garov on 2.03.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import WalletCore

class MarketCapViewController: UIViewController {
    
    fileprivate let disposeBag = DisposeBag()
    
    private var nextTrigger = PublishSubject<Void>()
    
    @IBOutlet weak var tableView: UITableView!
    fileprivate lazy var viewModel: MarketCapsViewModel = {
        return MarketCapsViewModel(trigger: self.nextTrigger.startWith( () ))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "AssetInfoTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "AssetInfoTableViewCell")
        tableView.backgroundView = BackgroundView(frame: tableView.bounds)
        
        viewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
    }
}

fileprivate extension MarketCapsViewModel {
    func bind(toViewController viewController: MarketCapViewController) -> [Disposable] {
        return [
            success
                .asObservable()
                .bind(to: viewController.tableView.rx.items(cellIdentifier: "AssetInfoTableViewCell", cellType: AssetInfoTableViewCell.self)) { (row, element, cell) in
                    cell.bind(toMarketCapItem: element)
                },
            loadingViewModel
                .isLoading
                .bind(to: viewController.rx.loading),
            
            errors.asObservable()
                .debug("MarketCap")
                .bind(to: viewController.rx.error)
        ]
    }
}
