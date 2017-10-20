//
//  BuyStep2ViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class BuyStep2ViewController: UIViewController, GraphProtocol {
    
    @IBOutlet weak var linearGraphView: TradingLinearGraphViewTest!
    @IBOutlet weak var periodsButtonsView: UIView!
    @IBOutlet weak var buyGraphLabel: UILabel!
    @IBOutlet weak var sellGraphLabel: UILabel!
    @IBOutlet weak var buyLabel: UILabel!
    @IBOutlet weak var sellLabel: UILabel!
    @IBOutlet weak var cryptoCurrencyLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var changeLbl: UILabel!
    @IBOutlet weak var buyLbl: UILabel!
    @IBOutlet weak var sellLbl: UILabel!
    @IBOutlet weak var buyBtn: UILabel!
    @IBOutlet weak var sellBtn: UILabel!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    private let disposeBag = DisposeBag()
    var periodButtons: [UIView]? = nil
    var periodButtonsArray: [PeriodButton] = []
    var assetPairId = "BTCUSD"
    var changeLabelP: UILabel = UILabel()
    var periodsButtonsViewP: UIView = UIView()
    var linearGraphViewP: TradingLinearGraphViewTest = TradingLinearGraphViewTest()
    var disposeBagP: DisposeBase = DisposeBag()
    
    var assetPairModel: LWAssetPairModel = LWAssetPairModel()
//    lazy var assetPairModel: LWAssetPairModel  = {
//        let assetPair = LWAssetPairModel.assetPair(withDict: ["Accuracy":"3", "BaseAssetId":"BTC", "Group":"LYKKE", "Id":"BTCUSD", "Inverted":"0", "InvertedAccuracy": "8", "Name":"BTC/USD", "QuotingAssetId":"USD"])
//        return assetPair!
//        }()

    
    lazy var graphViewModel: GraphDataViewModel = {
        return GraphDataViewModel(assetPairModel: self.assetPairModel , graphViewPoints: Int32(self.view.bounds.size.width/5))
    }()
    
    var graphViewModelP: GraphDataViewModel = GraphDataViewModel.init(assetPairModel: LWAssetPairModel.init(), graphViewPoints: Int32(375/5))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        buyLbl.text = Localize("buy.newDesign.buy")
        buyBtn.text = Localize("buy.newDesign.buy")
        sellLbl.text = Localize("buy.newDesign.sell")
        sellBtn.text = Localize("buy.newDesign.sell")
        changeLbl.text = Localize("buy.newDesign.change")
        changeLabelP = changeLabel
        linearGraphViewP = linearGraphView
        graphViewModelP = graphViewModel
        periodsButtonsViewP = periodsButtonsView
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clear
        
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
        
        graphViewModel.buy
            .drive(buyLabel.rx.text)
            .disposed(by: disposeBag)
        
        graphViewModel.buyGraph
            .drive(buyGraphLabel.rx.text)
            .disposed(by: disposeBag)
        
        graphViewModel.sell
            .drive(sellLabel.rx.text)
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
        
        imageHeight.constant =  Display.height
    }
    
    @IBAction func buyAction(_ sender: UIButton) {
//        guard let buyViewController = self.parent as? BuyViewController else {return}
//        buyViewController.sellPrice = false
//        buyViewController.buyActionStep3()
    }
    
    
    @IBAction func sellAction(_ sender: UIButton) {
//        guard let buyViewController = self.parent as? BuyViewController else {return}
//        buyViewController.sellPrice = true
//        buyViewController.buyActionStep3()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        let buyStep3VC = segue.destination as! BuyStep3ViewController
        
        if segue.identifier == "BuyStep3" {
            buyStep3VC.assetPairModel = assetPairModel
            buyStep3VC.askOrBid = false
        }
        else if segue.identifier == "SellStep3" {
            buyStep3VC.assetPairModel = assetPairModel
            buyStep3VC.askOrBid = true
        }
    }
 

}

class PeriodButton: UIButton {
    var period: LWGraphPeriodModel?
}
