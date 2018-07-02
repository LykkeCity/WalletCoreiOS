//
//  TransactionPickDateRangeViewController.swift
//  ModernMoney
//
//  Created by Lyubomir Marinov on 1.02.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import RxSwift
import RxCocoa

class TransactionPickDateRangeViewController: UIViewController {
    
    @IBOutlet weak var startDateButton: UIButton!
    @IBOutlet weak var endDateButton: UIButton!
    @IBOutlet weak var setFilterButton: UIButton!
    
    var filterViewModel: TransactionFilterViewModel?
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let filterViewModel = filterViewModel else { return }
        
        filterViewModel.bind(toVC: self)
            .disposed(by: disposeBag)
        
        // Show calendar screen after tapping any of the buttons
        startDateButton.rx.tap
            .flatMap { [weak self] in return TransactionCalendarViewController.pushCalendarViewController(from: self, withDate: self?.filterViewModel?.startDateValue) }
            .do(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .bind{ [filterViewModel] date in
                filterViewModel.startDateValue = date
            }
            .disposed(by: disposeBag)
        
        endDateButton.rx.tap
            .flatMap { [weak self] in return TransactionCalendarViewController.pushCalendarViewController(from: self, withDate: self?.filterViewModel?.endDateValue) }
            .do(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .bind{ [filterViewModel] date in
                filterViewModel.endDateValue = date
            }
            .disposed(by: disposeBag)
        
        setFilterButton.rx.tap.asObservable()
            .map{ [filterViewModel] in (start: filterViewModel.startDateValue, end: filterViewModel.endDateValue)}
            .do(onNext: { [weak self] _ in
                self?.navigationController?.dismiss(animated: true)
            })
            .bind(to: filterViewModel.filterDatePair)
            .disposed(by: disposeBag)
    }
}

extension TransactionFilterViewModel {
    func bind(toVC viewController: TransactionPickDateRangeViewController) -> [Disposable] {
        return [
            startButton.drive(viewController.startDateButton.rx.title),
            endButton.drive(viewController.endDateButton.rx.title),
            errors.drive(viewController.rx.error)
        ]
    }
}
