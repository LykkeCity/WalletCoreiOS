//
//  MarketCapTableViewController.swift
//  ModernMoney
//
//  Created by Vasil Garov on 2.03.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import WalletCore

class MarketCapTableViewController: UITableViewController {
    
    fileprivate let disposeBag = DisposeBag()
    
    private var nextTrigger = PublishSubject<Void>()
    
    fileprivate lazy var viewModel: MarketCapViewModel = {
        return MarketCapViewModel(trigger: self.nextTrigger, startIndex: 0, limit: 20)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "AssetInfoTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "AssetInfoTableViewCell")
        tableView.backgroundView = BackgroundView(frame: tableView.bounds)
    }
}
