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
import UIScrollView_InfiniteScroll

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
        
        tableView.addInfiniteScroll{ [nextTrigger] tableView in
            nextTrigger.onNext(())
        }
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
            
            success.drive(onNext: {[weak viewController]_ in
                viewController?.tableView.finishInfiniteScroll()
            }),
            
            loadingViewModel
                .isLoading
                .take(2) // take just first loading (true/false).All further loading indicators will be provided by UIScrollView_InfiniteScroll
                .bind(to: viewController.rx.loading),
            
            errors.asObservable()
                .bind(to: viewController.rx.error)
        ]
    }
}
