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
            .flatMap { [weak self] in return TransactionCalendarViewController.pushCalendarViewController(from: self, withDate: self?.filterViewModel?.startDate.value) }
            .do(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .filterNil()
            .filter{date in
                return self.compareDates(isStartDate: true, date: date)
            }
            .bind(to: filterViewModel.startDate)
            .disposed(by: disposeBag)
        
        endDateButton.rx.tap
            .flatMap { [weak self] in return TransactionCalendarViewController.pushCalendarViewController(from: self, withDate: self?.filterViewModel?.endDate.value) }
            .do(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .filterNil()
            .filter{date in
                return self.compareDates(isStartDate: false, date: date)
            }
            .bind(to: filterViewModel.endDate)
            .disposed(by: disposeBag)

        let datesObservable = Observable.combineLatest(filterViewModel.startDate
                                                        .asObservable()
                                                        .startWith(nil),
                                                       filterViewModel.endDate
                                                        .asObservable()
                                                        .startWith(nil)) { (start: $0, end: $1 ) }
        setFilterButton.rx.tap
            .withLatestFrom(datesObservable)
            .do(onNext: { [weak self] _ in
                self?.navigationController?.dismiss(animated: true)
            })
            .bind(to: filterViewModel.filterDatePair)
            .disposed(by: disposeBag)
    }
    
    func compareDates(isStartDate: Bool, date: Date) -> Bool  {

        var check: Bool
        if (isStartDate) {
            guard let endDate = (self.filterViewModel?.endDate.value) else { return true}
            check = date.compare(endDate) != ComparisonResult.orderedDescending
            if(!check) {
                self.view.makeToast(Localize("filter.newDesign.toast.message.startDate"))
            }
        }
        
        else {
            guard let startDate = (self.filterViewModel?.startDate.value) else { return true}
            check = date.compare(startDate) != ComparisonResult.orderedAscending
            if(!check) {
                self.view.makeToast(Localize("filter.newDesign.toast.message.endDate"))
            }
        }
        return check
    }
}

extension TransactionFilterViewModel {
    func bind(toVC viewController: TransactionPickDateRangeViewController) -> [Disposable] {
        return [
            startButton.drive(viewController.startDateButton.rx.title),
            endButton.drive(viewController.endDateButton.rx.title)
        ]
    }
}
