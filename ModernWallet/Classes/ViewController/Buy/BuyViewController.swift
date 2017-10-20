//
//  BuyViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 7/6/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import KYDrawerController
import RxSwift
import RxCocoa
import WalletCore

class BuyViewController: UIViewController, GraphProtocol {
    
    @IBOutlet weak var selectCurrencyLabel: UILabel!
    @IBOutlet weak var pageIndicatorContainer: UIStackView!
    @IBOutlet weak var pageIndicatorBtn1: UIButton!
    @IBOutlet weak var pageIndicatorBtn2: UIButton!
    @IBOutlet weak var pageIndicatorBtn3: UIButton!
    @IBOutlet weak var pageIndicatorBtn4: UIButton!
//    @IBOutlet weak var totalValueLabel: UILabel!
//    @IBOutlet weak var totalValueSymbol: UILabel!
//    @IBOutlet weak var totalValueLbl: UILabel!
    @IBOutlet weak var buyStep1: UIView!
    @IBOutlet weak var buyStep2: UIView!
    @IBOutlet weak var buyStep3: UIView!
    @IBOutlet weak var buyStep4: UIView!
    @IBOutlet weak var graphBtn: UIButton!
    @IBOutlet weak var buyTitleLbl: UILabel!
    @IBOutlet weak var graphContainerView: UIView!
    @IBOutlet weak var linearGraphView: TradingLinearGraphViewTest!
    @IBOutlet weak var periodsButtonsView: UIView!
    @IBOutlet weak var buyGraphLabel: UILabel!
    @IBOutlet weak var sellGraphLabel: UILabel!
    @IBOutlet weak var cryptoCurrencyLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var changeLbl: UILabel!
    @IBOutlet weak var buyLbl: UILabel!
    @IBOutlet weak var sellLbl: UILabel!
    @IBOutlet weak var totalBalanceView: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    
    private let disposeBag = DisposeBag()
    
    var assets = Variable<[Variable<Asset>]>([])
    let balanceViewModel = TotalBalanceViewModel()
    
    var periodButtons: [UIView]? = nil
    var periodButtonsArray: [PeriodButton] = []
//    var assetPairId = "BTCUSD"
    var changeLabelP: UILabel = UILabel()
    var periodsButtonsViewP: UIView = UIView()
    var linearGraphViewP: TradingLinearGraphViewTest = TradingLinearGraphViewTest()
    var disposeBagP: DisposeBase = DisposeBag()
    var sellPrice: Bool = false
    
    var navController: UINavigationController? {
        return (childViewControllers.first{$0 is UINavigationController}) as? UINavigationController
    }
    
    var pageIndicators: [UIButton] {
        return [pageIndicatorBtn1, pageIndicatorBtn2, pageIndicatorBtn3, pageIndicatorBtn4]
    }
    
//    lazy var assetPairModel: LWAssetPairModel  = {
//        let assetPair = LWAssetPairModel.assetPair(withDict: ["Accuracy":"3", "BaseAssetId":"BTC", "Group":"LYKKE", "Id":"BTCUSD", "Inverted":"0", "InvertedAccuracy": "8", "Name":"BTC/USD", "QuotingAssetId":"USD"])
//        return assetPair!
//    }()
    
    lazy var graphViewModel: GraphDataViewModel = {
        return GraphDataViewModel(assetPairModel: self.assetPairModel , graphViewPoints: Int32(self.view.bounds.size.width/5))
    }()
    
    var assetPairModel: LWAssetPairModel = LWAssetPairModel()
    var graphViewModelP: GraphDataViewModel = GraphDataViewModel.init(assetPairModel: LWAssetPairModel.init(), graphViewPoints: Int32(375/5))

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navController?.delegate = self
        setUserInterface()
    }
    
    func graphSetUp() {
        changeLabelP = changeLabel
        linearGraphViewP = linearGraphView
        graphViewModelP = graphViewModel
        periodsButtonsViewP = periodsButtonsView
        
        graphViewModel.periodArray
            .take(1)
            .subscribe(onNext: {[weak self] periodArray in self?.updatePeriodButtons(periodArray: periodArray)})
            .disposed(by: disposeBag)
        
        graphViewModel.graphData
            .subscribe(onNext: {[weak self] graphData in self?.updateGraph(graphData: graphData)})
            .disposed(by: disposeBag)
        
        graphViewModel.selectedPeriod.asObservable()
            .filterNil()
            .subscribe(onNext: {[weak self] selectedPeriod in self?.updateSelectedButton(period: selectedPeriod)})
            .disposed(by: disposeBag)
        
        
        graphViewModel.buyGraph
            .drive(buyGraphLabel.rx.text)
            .disposed(by: disposeBag)
        
        
        graphViewModel.sellGraph
            .drive(sellGraphLabel.rx.text)
            .disposed(by: disposeBag)
        
        graphViewModel.cryptoCurrency
            .drive(cryptoCurrencyLabel.rx.text)
            .disposed(by: disposeBag)
        
        graphViewModel.loading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(graphTapped))
        linearGraphView.addGestureRecognizer(gesture)
        linearGraphView.isUserInteractionEnabled = true
    }
    
    func graphTapped() {
        graphContainerView.isHidden = true
        graphBtn.isHidden = false
        backButton.isHidden = false
        buyTitleLbl.isHidden = false
        totalBalanceView.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUserInterface() {
        
        pageIndicatorBtn1.isSelected = true
        pageIndicatorBtn2.isSelected = false
        pageIndicatorBtn3.isSelected = false
        pageIndicatorBtn4.isSelected = false
        
        setUserInterfaceData(showingInd: true)
    }
    
    func setUserInterfaceData(showingInd: Bool) {
        
        pageIndicatorBtn1.isHidden = !showingInd
        pageIndicatorBtn2.isHidden = !showingInd
        pageIndicatorBtn3.isHidden = !showingInd
        pageIndicatorBtn4.isHidden = !showingInd
        
        self.graphBtn.isHidden = showingInd
        self.buyTitleLbl.isHidden = showingInd
        graphContainerView.isHidden = showingInd
    }
    

    
    @IBAction func backAction(_ sender:UIButton) {
        navController?.popViewController(animated: true)
    }
    
    @IBAction func onBackTap(_ sender: UIButton) {
        if let drawerController = self.parent as? KYDrawerController {
            let mainStory = UIStoryboard.init(name: "Main", bundle: nil)
            drawerController.mainViewController = mainStory.instantiateViewController(withIdentifier: "Portfolio")
        }
    }
    
    
    @IBAction func showGraph(_ sender: UIButton) {
        graphContainerView.isHidden = false
        sender.isHidden = true
        backButton.isHidden = true
        buyTitleLbl.isHidden = true
        totalBalanceView.isHidden = true

    }
}

extension BuyViewController: NavigationWizzardProtocol, UINavigationControllerDelegate {
    func getMaxIndicatorCount(_ navigationController: UINavigationController, willShow viewController: UIViewController) -> Int {
        if (navigationController.childViewControllers.filter{$0 is BuyStep4ViewController}).isNotEmpty {
            setUserInterfaceData(showingInd: false)
            graphTapped()
            return 0
        }
        if (navigationController.childViewControllers.filter{$0 is BuyStep3ViewController}).isNotEmpty {
            setUserInterfaceData(showingInd: false)
            graphTapped()
            return 0
        }
        if (navigationController.childViewControllers.filter{$0 is BuyStep2ViewController}).isNotEmpty {
            setUserInterfaceData(showingInd: true)
            return 0
        }
        if (navigationController.childViewControllers.filter{$0 is BuyStep1ViewController}).isNotEmpty {
            setUserInterfaceData(showingInd: false)
            graphTapped()
            return 4
        }
        else {
            setUserInterfaceData(showingInd: true)
            return 4
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        manageBackButtonVisibility(navigationController, willShow: viewController)
        managePageIndicators(navigationController, willShow: viewController)
        selectCurrencyLabel.isHidden = navigationController.childViewControllers.count > 1
    }
    
    func managePageIndicators(_ navigationController: UINavigationController, willShow viewController: UIViewController) {
        if navigationController.childViewControllers.count <= 1 {
            pageIndicators.forEach{$0.isHidden = false}
            return
        }
        
        let maxIndicatorsCount = getMaxIndicatorCount(navigationController, willShow: viewController)
        
        pageIndicators.enumerated().forEach{(index, button) in
            button.isHidden = index >= maxIndicatorsCount
        }
        
        pageIndicators.enumerated().forEach{(index, button) in
            button.isSelected = navigationController.childViewControllers.count - 2 == index
        }
    }
}
