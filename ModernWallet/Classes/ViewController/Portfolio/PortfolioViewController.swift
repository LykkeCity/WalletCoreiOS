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
    
    @IBOutlet weak var filterContainer: UIStackView!
    @IBOutlet weak var fiatFilterButton: IconOverTextButton!
    @IBOutlet weak var allFilterButton: IconOverTextButton!
    @IBOutlet weak var cryptoFilterButton: IconOverTextButton!
    
    @IBOutlet weak var tableHeader: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var pieChartCenterView: PieChartCenter!
    @IBOutlet weak var emptyPortfolioView: EmptyPortfolioView!
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let pieChartValueFormatter = PieValueFormatter()
        
    var filterButtonsMap: [AssetsFilterViewModel.FilterType: IconOverTextButton] {
        return [
            AssetsFilterViewModel.FilterType.all: self.allFilterButton,
            AssetsFilterViewModel.FilterType.crypto: self.cryptoFilterButton,
            AssetsFilterViewModel.FilterType.fiat: self.fiatFilterButton,
        ]
    }
    
    private let reloadTrigger = ReloadTrigger.instance.trigger(interval: 10).shareReplay(1)
    
    fileprivate lazy var walletsViewModel: WalletsViewModel = {
        return WalletsViewModel(
            refreshWallets: self.reloadTrigger
        )
    }()
    
    fileprivate lazy var kycGetStatusViewModel: KycGetStatusViewModel = {
        return KycGetStatusViewModel()
    }()
    
    fileprivate lazy var loadingViewModel: LoadingViewModel = {
        return LoadingViewModel([
            self.kycGetStatusViewModel.loadingViewModel.isLoading,
            self.walletsViewModel.loadingViewModel.isLoading.take(2) // prevent the loading indicator to appear when this request is refreshed
            ])
    }()
    
    fileprivate lazy var assetsFilterViewModel = {
        return AssetsFilterViewModel(assetsToFilter: self.walletsViewModel.wallets)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.backgroundColor = UIColor.clear
        configurePieChart()
        configureTableView()
        
        if UserDefaults.standard.isNotLoggedIn || SignUpStep.instance != nil {
            return
        }
        
        //notify that the application is oppened (Dev note : LMW-581)
        NotificationCenter.default.post(name: .applicationOpened, object: nil)
        
        tableView.register(UINib(nibName: "AssetInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "AssetInfoTableViewCell")
        
        //Bind table
        tableView.rx
            .modelSelected(Variable<Asset>.self)
            .map{ [assetsFilterViewModel] selectedAsset in
                assetsFilterViewModel.filteredAssets.asObservable()
                    .map(toAsset: selectedAsset)
            }
            .subscribe(onNext: { [weak self] model in
                self?.performSegue(withIdentifier: "assetDetail", sender: model)
            })
            .disposed(by: disposeBag)
        
        //Bind buttons that shows add money
        Observable
            .merge(
                emptyPortfolioView.addMoneyButton.rx.tap.asObservable(),
                pieChartCenterView.addMoneyButton.rx.tap.asObservable()
            )
            .subscribe(onNext: {[weak self] _ in
                self?.performSegue(withIdentifier: "AddMoney", sender: nil)
            })
            .disposed(by: disposeBag)
        
        bindViewModels()
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
        pieChartView.noDataText = ""
        pieChartView.renderer = StrokeChartRenderer(chart: pieChartView, animator: pieChartView.chartAnimator, viewPortHandler: pieChartView.viewPortHandler)
        pieChartView.holeColor = UIColor.clear
        pieChartView.highlightPerTapEnabled = false
        pieChartView.chartDescription = nil
        pieChartView.legend.enabled = false
        pieChartView.drawCenterTextEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let assetViewController = segue.destination as? AssetDetailViewController,
            let asset = sender as? Observable<Asset>
        {
            assetViewController.asset = asset
        }
    }
}


// MARK: - AssetsFilterViewModel binders to PortfolioViewController
fileprivate extension AssetsFilterViewModel {
    
    private func bindPieChart(toViewController viewController: PortfolioViewController) -> Disposable {
        let pieChartView = viewController.pieChartView
        let pieChartValueFormatter = viewController.pieChartValueFormatter
        
        return Driver
            .merge(filteredAssets.mapToPieChartDataSet(filteredSum: self.filteredSum), filteredAssets.mapToEmptyChart())
            .drive(onNext: { dataSet in
                
                dataSet.colors = [UIColor.clear]
                dataSet.valueFormatter = pieChartValueFormatter
                pieChartView?.data = PieChartData(dataSet: dataSet)
                pieChartView?.data?.setValueFont(UIFont(name: "GEOMANIST", size: 16))
            })
    }
    
    private func bind(toTableView tableView: UITableView) -> Disposable {
        return filteredAssets.asObservable()
            .map{ $0.sorted{ $0.0.value.percent > $0.1.value.percent } }
            .bind(to: tableView.rx.items(cellIdentifier: "AssetInfoTableViewCell", cellType: AssetInfoTableViewCell.self)) { (row, element, cell) in
                cell.bind(toAsset: AssetCellViewModel(element))
        }
    }
    
    private func bindFilter(toViewController viewController: PortfolioViewController) -> Disposable {
        return Observable
            .merge(
                viewController.allFilterButton.rx.tap.map{ _ in AssetsFilterViewModel.FilterType.all },
                viewController.cryptoFilterButton.rx.tap.map{ _ in AssetsFilterViewModel.FilterType.crypto },
                viewController.fiatFilterButton.rx.tap.map{ _ in AssetsFilterViewModel.FilterType.fiat }
            )
            .distinctUntilChanged()
            .bind(to: filter)
    }
    
    private func bindFilterButtonsState(toViewController viewController: PortfolioViewController) -> Disposable {
        let filterButtonsMap = viewController.filterButtonsMap
        
        return filter.asDriver().drive(onNext: { filterType in
            filterButtonsMap.forEach{ arg in
                let (key, value) = arg
                value.isSelected = key == filterType
            }
        })
    }
    
    func bind(toViewController viewController: PortfolioViewController) -> [Disposable] {
        return [
            bindPieChart(toViewController: viewController),
            bind(toTableView: viewController.tableView),
            bindFilter(toViewController: viewController),
            bindFilterButtonsState(toViewController: viewController)
        ]
    }
}

// MARK: - WalletsViewModel binders to PortfolioViewController
fileprivate extension WalletsViewModel {
    func bind(toViewController viewController: PortfolioViewController) -> [Disposable] {
        
        return [
            isEmpty.asDriver()
                .startWith(true)
                .map{ !$0 }
                .drive(viewController.emptyPortfolioView.rx.isHidden),
            
            isEmpty.asDriver()
                .startWith(true)
                .drive(viewController.pieChartCenterView.addMoneyButton.rx.isHidden),
            
            isEmpty.asDriver()
                .startWith(true)
                .drive(viewController.filterContainer.rx.isHidden),
 
            baseAsset
                .subscribe(onNext: { LWCache.instance().baseAssetId = $0.identity }),
            
            totalBalance
                .drive(viewController.pieChartCenterView.balanceLabel.rx.text),
            
            currencyName
                .drive(viewController.pieChartCenterView.currencyName.rx.text)
        ]
    }
}

// MARK: - KycGetStatusViewModel binder to PortfolioViewController {
fileprivate extension KycGetStatusViewModel {    
    func bind(toViewController viewController: PortfolioViewController) -> Disposable {
        return kycStatusОк
            .subscribe(onNext: { [weak viewController] _ in
                
                guard let kycFinishedViewController = UIStoryboard(name: "KYC", bundle: nil)
                        .instantiateViewController(withIdentifier: "kycFinishedVC")
                            as? KYCFinishedViewController else { return }
                
                viewController?.present(kycFinishedViewController, animated: true, completion: {
                    UserDefaults.standard.set(LWKeychainManager.instance().login, forKey: KycGetStatusViewModel.kycSaveKey)
                })
            })
    }
}

// MARK: - PortfolioViewController view model binder
fileprivate extension PortfolioViewController {
    func bindViewModels() {
        walletsViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        assetsFilterViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        kycGetStatusViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)

        loadingViewModel.isLoading
            .startWith(true)
            .asDriver(onErrorJustReturn: false)
            .drive(rx.loading)
            .disposed(by: disposeBag)
    }
}


// MARK: - RX custom operators
fileprivate extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, Self.E == [Variable<Asset>] {
    func mapToPieChartDataSet(filteredSum: Driver<Decimal>) -> Driver<PieChartDataSet> {
        
        return
            filter{ $0.isNotEmpty }
                .map { $0.filter{$0.value.percent > 0} }
                .withLatestFrom(filteredSum) { (assets: $0, filteredSum: $1) }
                .map { value in
                    value.assets.map {
                        let percentFilter = ($0.value.realCurrency.value / value.filteredSum).doubleValue * 100
                        return PieChartDataEntry(value: percentFilter, data: $0.value) }
                }
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

fileprivate extension ObservableType where Self.E == [Variable<Asset>] {
    
    /// <#Description#>
    ///
    /// - Parameter asset: <#asset description#>
    /// - Returns: <#return value description#>
    func map(toAsset asset: Variable<Asset>) -> Observable<Asset> {
        return map{ $0.first{ $0.value.wallet?.identity == asset.value.wallet?.identity  } }
            .map{ $0?.value }
            .filterNil()
    }
}

fileprivate extension ObservableType where Self.E == [Variable<Asset>] {
    func asDriver() -> Driver<[Variable<Asset>]> {
        return asDriver(onErrorJustReturn: [])
    }
}
