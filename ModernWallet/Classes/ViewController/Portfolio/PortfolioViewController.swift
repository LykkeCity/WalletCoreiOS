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
    @IBOutlet weak var emptyPortfolioView: EmptyPortfolioView!
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let pieChartValueFormatter = PieValueFormatter()
    fileprivate lazy var totalBalanceViewModel: TotalBalanceViewModel = {
        
        return TotalBalanceViewModel(refresh: Observable
            .merge(
                Observable<Void>.interval(10.0),
                self.reloadTrigger.asObservable().filterNil()
            )
            .throttle(2.0, scheduler: MainScheduler.instance)
        )
    }()
    
    
    /// A variable that it's used for reloading portfolio data.
    /// When the value is changed it triggers an event that will reload all data needed for that screen.
    private let reloadTrigger = Variable<Void?>(nil)
    
    fileprivate lazy var walletsViewModel: WalletsViewModel = {
        return WalletsViewModel(
            refreshWallets: self.reloadTrigger.asObservable().filterNil(),
            mainInfo: self.totalBalanceViewModel.observables.mainInfo.filterSuccess()
        )
    }()
    
    fileprivate lazy var loadingViewModel: LoadingViewModel = {
        return LoadingViewModel([
            self.totalBalanceViewModel.loading.isLoading.debug("GG: Loading Balance", trimOutput: false),
            self.walletsViewModel.loadingViewModel.isLoading.debug("GG: Loading Wallets", trimOutput: false)
        ])
    }()
    
    var assets = Variable<[Variable<Asset>]>([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(PortfolioViewController.reloadData), name: .loggedIn, object: nil)
        

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        configurePieChart()
        configureTableView()
        
        tableView.register(UINib(nibName: "PortfolioCurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: "PortfolioCurrencyTableViewCell")
        
        //Bind table
        assets.asObservable()
            .map{$0.sorted{$0.0.value.percent > $0.1.value.percent}}
            .bind(to: tableView.rx.items(cellIdentifier: "PortfolioCurrencyTableViewCell", cellType: PortfolioCurrencyTableViewCell.self)) { (row, element, cell) in
                cell.bind(toAsset: AssetCellViewModel(element))
            }
            .disposed(by: disposeBag)

        //Bind show/hide according to empty wallets
        assets.asDriver()
            .map{$0.isNotEmpty}
            .drive(emptyPortfolioView.rx.isHidden)
            .disposed(by: disposeBag)
        
        assets.asDriver()
            .map{$0.isEmpty}
            .drive(pieChartCenterView.addMoneyButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        //Bind piechart
        Driver
            .merge(
                assets.asDriver().mapToPieChartDataSet(),
                assets.asDriver().mapToEmptyChart()
            )
            .drive(onNext: {[pieChartView, pieChartValueFormatter] dataSet in
                
                dataSet.colors = [UIColor.clear]
                dataSet.valueFormatter = pieChartValueFormatter
                pieChartView?.data = PieChartData(dataSet: dataSet)
                pieChartView?.data?.setValueFont(UIFont(name: "GEOMANIST", size: 16))
            })
            .disposed(by: disposeBag)
    
        //Bind buttons that shows add money
        Observable
            .merge(
                emptyPortfolioView.addMoneyButton.rx.tap.asObservable(),
                pieChartCenterView.addMoneyButton.rx.tap.asObservable()
            )
            .subscribe(onNext: {[weak self] _ in
                guard let controller = self?.storyboard?.instantiateViewController(withIdentifier: "AddMoney") else{return}
                guard let drawerController = self?.parent as? KYDrawerController else{return}
                
                drawerController.mainViewController = controller
            })
            .disposed(by: disposeBag)
        
        bindViewModels()
        
        //show signUp methods this should be test for auth
        if((UserDefaults.standard.value(forKey: "loggedIn")) != nil) {
            reloadData()
        }
    }
    
    
    /// Trigger an event that will trigger reloading data for wallets, base asset and total balance
    func reloadData()  {
        reloadTrigger.value = Void()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if((UserDefaults.standard.value(forKey: "loggedIn")) == nil) {
            let signInStory = UIStoryboard.init(name: "SignIn", bundle: nil)
            let signUpNav = signInStory.instantiateViewController(withIdentifier: "SignUpNav")
            self.parent?.present(signUpNav, animated: false, completion: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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

fileprivate extension TotalBalanceViewModel {
    func bind(toVieController viewController: PortfolioViewController) -> [Disposable] {
        return [
            observables.baseAsset.filterSuccess().subscribe(onNext: {asset in LWCache.instance().baseAssetId = asset.identity}),
            balance.drive(viewController.pieChartCenterView.balanceLabel.rx.text),
            currencyName.drive(viewController.pieChartCenterView.currencyName.rx.text)
        ]
    }
}

extension PortfolioViewController {
    func bindViewModels() {
        
        totalBalanceViewModel
            .bind(toVieController: self)
            .disposed(by: disposeBag)
        
        walletsViewModel.wallets
            .bind(to: assets)
            .disposed(by: disposeBag)
        
        loadingViewModel.isLoading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
    }
}

fileprivate extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, Self.E == [Variable<Asset>] {
    func mapToPieChartDataSet() -> Driver<PieChartDataSet> {
        return
            filter{$0.isNotEmpty}
            .map{$0.filter{$0.value.percent > 0}}
            .map{$0.map{PieChartDataEntry(value: $0.value.percent, data: $0.value)}}
            .map{PieChartDataSet(values: $0, label: nil)}
    }
    
    func mapToEmptyChart() -> Driver<PieChartDataSet> {
        return filter{$0.isEmpty}
            .map{_ in [
                PieChartDataEntry(value: 20.0, data: "0%" as AnyObject),
                PieChartDataEntry(value: 30.0, data: "0%" as AnyObject),
                PieChartDataEntry(value: 40.0, data: "0%" as AnyObject)
            ]}
            .map{PieChartDataSet(values: $0, label: nil)}
    }
}
