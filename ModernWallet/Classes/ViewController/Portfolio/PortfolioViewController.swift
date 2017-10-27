//
//  PortfolioViewController.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 6/5/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Charts
import KYDrawerController
import WalletCore

class PortfolioViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var pieChartCenterView: PieChartCenter!

    private let disposeBag = DisposeBag()
    private let pieChartValueFormatter = PieValueFormatter()
    private lazy var totalBalanceViewModel: TotalBalanceViewModel = {
        return TotalBalanceViewModel()
    }()
    
    private lazy var walletsViewModel: WalletsViewModel = {
        return WalletsViewModel(
            withBaseAsset: self.totalBalanceViewModel.observables.baseAsset.filterSuccess(),
            mainInfo: self.totalBalanceViewModel.observables.mainInfo.filterSuccess()
        )
    }()
    
    private lazy var loadingViewModel: LoadingViewModel = {
        return LoadingViewModel([
            self.totalBalanceViewModel.loading.isLoading,
            self.walletsViewModel.isLoading
        ])
    }()
    
    var assets = Variable<[Variable<Asset>]>([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(PortfolioViewController.loadData), name: .loggedIn, object: nil)
        

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
//        let authmanager = LWAuthManager.instance()
//        authmanager?.requestSwiftCredential("CHF")
        
        configurePieChart()
        configureTableView()
        
        tableView.register(UINib(nibName: "PortfolioCurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: "PortfolioCurrencyTableViewCell")
        
        assets.asObservable()
            .map{$0.sorted{$0.0.value.percent > $0.1.value.percent}}
            .bind(to: tableView.rx.items(cellIdentifier: "PortfolioCurrencyTableViewCell", cellType: PortfolioCurrencyTableViewCell.self)) { (row, element, cell) in
                cell.bind(toAsset: AssetCellViewModel(element))
            }
            .disposed(by: disposeBag)

        assets.asDriver()
            .map{$0.filter{$0.value.percent > 0}}
            .map{$0.map{PieChartDataEntry(value: $0.value.percent, data: $0.value)}}
            .map{PieChartDataSet(values: $0, label: nil)}
            .drive(onNext: {[weak self] dataSet in
                guard let this = self else {return}
                
                dataSet.colors = [UIColor.clear]
                dataSet.valueFormatter = this.pieChartValueFormatter
//                dataSet.selectionShift = 0
                this.pieChartView.data = PieChartData(dataSet: dataSet)
                this.pieChartView.data?.setValueFont(UIFont(name: "GEOMANIST", size: 16))
            })
            .disposed(by: disposeBag)
    
        pieChartCenterView.addMoneyButton.rx.tap.asObservable()
            .subscribe(onNext: {[weak self] _ in
                guard let controller = self?.storyboard?.instantiateViewController(withIdentifier: "AddMoney") else{return}
                guard let drawerController = self?.parent as? KYDrawerController else{return}
                
                drawerController.mainViewController = controller
            })
            .disposed(by: disposeBag)
        
        //show signUp methods this should be test for auth
        if((UserDefaults.standard.value(forKey: "loggedIn")) != nil) {
            loadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if((UserDefaults.standard.value(forKey: "loggedIn")) == nil) {
            let signInStory = UIStoryboard.init(name: "SignIn", bundle: nil)
            let signUpNav = signInStory.instantiateViewController(withIdentifier: "SignUpNav")
            self.parent?.present(signUpNav, animated: false, completion: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadData() {
        totalBalanceViewModel.observables.baseAsset
            .filterSuccess()
            .subscribe(onNext: {asset in
                LWCache.instance().baseAssetId = asset.identity
            })
            .disposed(by: disposeBag)
        
        
        totalBalanceViewModel.balance
            .drive(pieChartCenterView.balanceLabel.rx.text)
            .disposed(by: disposeBag)
        
        totalBalanceViewModel.currencyName
            .drive(pieChartCenterView.currencyName.rx.text)
            .disposed(by: disposeBag)
        
        walletsViewModel.wallets
            .bind(to: assets)
            .disposed(by: disposeBag)
        
        loadingViewModel.isLoading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configureTableView() {
        tableView.backgroundColor = UIColor.clear
    }
    
    /// Add colors, renerer at cetera to pie chart
    private func configurePieChart() {
        pieChartView.renderer = StrokeChartRenderer(chart: pieChartView, animator: pieChartView.chartAnimator, viewPortHandler: pieChartView.viewPortHandler)
        pieChartView.holeColor = UIColor.clear
        pieChartView.highlightPerTapEnabled = false
        pieChartView.chartDescription = nil
        pieChartView.legend.enabled = false
        pieChartView.drawCenterTextEnabled = false
    }
}
