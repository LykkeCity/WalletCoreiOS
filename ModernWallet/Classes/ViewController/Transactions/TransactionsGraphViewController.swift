//
//  TransactionsGraphViewController.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 7/17/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import Charts
import RxCocoa
import RxSwift
import WalletCore

class TransactionsGraphViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var lineChartView: LineChartView!
    let graphValue: Variable<(model: LWHistoryGraphModel, highlight: Highlight)?> = Variable(nil)
    
    lazy var baseValueView: UIStackView = self.stackViewFactory()
    lazy var cryptoValueView: UIStackView = self.stackViewFactory()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        
        lineChartView.setup()
        
        let dataSet = LineChartDataSet(values: FakeData.historyGraphData, label: nil).setup()
        lineChartView.data = LineChartData(dataSet: dataSet)
        lineChartView.delegate = self
     
        bindHint()
    }
    
    func bindHint() {
        graphValue.asDriver().filterNil()
            .map{(
                value: $0.model.value.value.convertAsCurrency(currecy: $0.model.value),
                currencyCode: $0.model.value.shortName,
                highlight: $0.highlight,
                isAbove: false
            )}
            .drive(cryptoValueView.rx.graphHint)
            .disposed(by: disposeBag)
        
        graphValue.asDriver().filterNil()
            .map{(
                value: $0.model.baseValue.value.convertAsCurrency(currecy: $0.model.baseValue),
                currencyCode: $0.model.baseValue.shortName,
                highlight: $0.highlight,
                isAbove: true
            )}
            .drive(baseValueView.rx.graphHint)
            .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let historyGraphModel = entry.data as? LWHistoryGraphModel else {return}
        graphValue.value = (model: historyGraphModel, highlight: highlight)
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        graphValue.value = nil
    }
    
    func stackViewFactory() -> UIStackView {
        let valueBase = UILabel()
        valueBase.font  = UIFont(name: "GEOMANIST", size: 16.1)
        valueBase.textAlignment = .right
        valueBase.textColor = UIColor.white
        
        let currencyCode = UILabel()
        currencyCode.font = UIFont(name: "GEOMANIST", size: 5.9)
        currencyCode.textColor = UIColor.white
        currencyCode.textAlignment = .left
        
        let stackView = UIStackView(arrangedSubviews: [valueBase, currencyCode])
        stackView.alignment = .firstBaseline
        stackView.spacing = CGFloat(3.3)
        
        self.view.addSubview(stackView)
        
        return stackView
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

