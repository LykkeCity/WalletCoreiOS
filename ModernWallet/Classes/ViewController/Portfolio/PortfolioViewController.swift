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
    fileprivate var loadingDisposeBag = DisposeBag()
    fileprivate let pieChartValueFormatter = PieValueFormatter()
    
    fileprivate lazy var totalBalanceViewModel: TotalBalanceViewModel = {
        return TotalBalanceViewModel(refresh: Observable<Void>.interval(10.0))
    }()
    
    fileprivate lazy var walletsViewModel: WalletsViewModel = {
        return WalletsViewModel(
            refreshWallets: Observable.just(Void()),
            mainInfo: self.totalBalanceViewModel.observables.mainInfo.filterSuccess()
        )
    }()
    
    fileprivate lazy var loadingViewModel: LoadingViewModel = {
        return LoadingViewModel([
            self.totalBalanceViewModel.loading.isLoading,
            self.walletsViewModel.loadingViewModel.isLoading
        ])
    }()
    
    var assets = Variable<[Variable<Asset>]>([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.backgroundColor = UIColor.clear
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
            .map{ $0.isNotEmpty }
            .drive(emptyPortfolioView.rx.isHidden)
            .disposed(by: disposeBag)
        
        assets.asDriver()
            .map{$0.isEmpty}
            .drive(pieChartCenterView.addMoneyButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        if UserDefaults.standard.value(forKey: "loggedIn") == nil {
            return
        }
        
        tableView.rx
            .modelSelected(Variable<Asset>.self)
            .subscribe(onNext: { [weak self] model in
                self?.performSegue(withIdentifier: "assetDetail", sender: model)
            })
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
            .subscribe(onNext: {[storyboard, parent] _ in
                guard let controller = storyboard?.instantiateViewController(withIdentifier: "AddMoney") else{ return }
                guard let drawerController = parent as? KYDrawerController else{ return }
                
                drawerController.mainViewController = controller
            })
            .disposed(by: disposeBag)
        
        bindViewModels()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        loadingDisposeBag = DisposeBag()
        
        loadingViewModel.isLoading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let assetViewController = segue.destination as? AssetDetailViewController,
           let asset = sender as? Variable<Asset>
        {
            assetViewController.asset = asset
        }
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
    }
}

fileprivate extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, Self.E == [Variable<Asset>] {
    func mapToPieChartDataSet() -> Driver<PieChartDataSet> {
        return
            filter{ $0.isNotEmpty }
            .map{ $0.filter{$0.value.percent > 0} }
            .map{ $0.map{ PieChartDataEntry(value: $0.value.percent, data: $0.value) } }
            .map{ PieChartDataSet(values: $0, label: nil) }
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
