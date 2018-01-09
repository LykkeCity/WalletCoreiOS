//
//  TransactionsStep1ViewController.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 7/11/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import WalletCore

class TransactionsStep1ViewController: UIViewController {

    @IBOutlet weak var findTransactionBtn: UIButton!
    @IBOutlet weak var filterTransactionBtn: UIButton!
    @IBOutlet weak var downloadCSV: UIButton!
    @IBOutlet weak var transactionsTableView: UITableView!
    @IBOutlet weak var findTransactionLbl: UILabel!
    @IBOutlet weak var filterTransactionLbl: UILabel!
    @IBOutlet weak var downloadCSVLbl: UILabel!
    
    let disposeBag = DisposeBag()
    lazy var transactionsViewModel:TransactionsViewModel = {
        return TransactionsViewModel(
            downloadCsv: self.downloadCSV.rx.tap.asObservable(),
            currencyExchanger: CurrencyExchanger()
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        
        findTransactionLbl.text = Localize("transaction.newDesign.findTransaction")
        filterTransactionLbl.text = Localize("transaction.newDesign.filterTransaction")
        downloadCSVLbl.text = Localize("transaction.newDesign.downoloadCSV")
        
        transactionsTableView.register(UINib(nibName: "PortfolioCurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: "PortfolioCurrencyTableViewCell")
        
        filterTransactionBtn.rx.tap.asObservable()
            .map{[transactionsViewModel] in transactionsViewModel.sortBy.value.reversed }
            .bind(to: transactionsViewModel.sortBy)
            .disposed(by: disposeBag)
        
        transactionsViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func creatCSV(_ path: URL) -> Void {
        let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
        present(vc, animated: true, completion: nil)
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

fileprivate extension TransactionsViewModel {
    func bind(toViewController vc: TransactionsStep1ViewController) -> [Disposable] {
        return [
            transactions.asObservable()
                .bind(to: vc.transactionsTableView.rx.items(cellIdentifier: "PortfolioCurrencyTableViewCell",
                                                            cellType: PortfolioCurrencyTableViewCell.self)
                ){ (row, element, cell) in cell.bind(toTransaction: element) }
            ,
            loading.isLoading.bind(to: vc.rx.loading),
            transactionsAsCsv.filterSuccess().drive(onNext: {[weak vc] path in vc?.creatCSV(path)})
        ]
    }
}
