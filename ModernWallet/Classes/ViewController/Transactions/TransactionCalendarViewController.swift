//
//  TransactionCalendarViewController.swift
//  ModernMoney
//
//  Created by Lyubomir Marinov on 2.02.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Koyomi

class TransactionCalendarViewController: UIViewController {
    
    @IBOutlet weak var previousMonthButton: UIButton!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var nextMonthButton: UIButton!
    
    @IBOutlet weak var calendar: Koyomi! {
        didSet {
            calendar.backgroundColor = UIColor.clear
            calendar.selectionMode = .single(style: .background)
            calendar.weeks = ("Mo", "Tu", "We", "Th", "Fr", "Sa", "Su")
            calendar.currentDateFormat = "MMMM YYYY"
            calendar.setDayFont(fontName: "Geomanist-Light", size: 12)
            calendar.setWeekFont(fontName: "Geomanist-Light", size: 12)
            calendar.selectedStyleColor = UIColor.white.withAlphaComponent(0.5)
            let customColorScheme = (dayBackgrond: UIColor.clear,
                       weekBackgrond: UIColor.clear,
                       week: UIColor.white,
                       weekday: UIColor.white,
                       holiday: (saturday: UIColor.white, sunday: UIColor.white),
                       otherMonth: UIColor.white.withAlphaComponent(0.5),
                       separator: UIColor.clear)
            
            calendar.style = KoyomiStyle.custom(customColor: customColorScheme)
        }
    }
    
    /// Input date
    public var inputDate: Date?
    /// Output value representing the date selected by the user on this screen
    public var selectedDate = PublishSubject<Date?>()
    
    let disposeBag = DisposeBag()
    
    /// Push view controller and expose an Observable<Date?>
    static func pushCalendarViewController(from viewController: UIViewController, withDate date: Date?) -> Observable<Date?> {
        guard let calendarViewController = UIStoryboard(name: "Transactions", bundle: nil)
                .instantiateViewController(withIdentifier: "CalendarViewController") as? TransactionCalendarViewController else {
            return Observable.never()
        }
        
        calendarViewController.inputDate = date
        
        viewController.navigationController?.pushViewController(calendarViewController, animated: true)
        return calendarViewController.selectedDate.asObservable()
            .shareReplay(1)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initial setup
        calendar.select(date: inputDate ?? Date())
        monthLabel.text = calendar.currentDateString(withFormat: "MMMM YYYY")
        
        // Bind the `<` & `>` buttons
        previousMonthButton.rx.tap
            .bind(to: calendar.rx.prevMonth)
            .disposed(by: disposeBag)
        
        nextMonthButton.rx.tap
            .bind(to: calendar.rx.nextMonth)
            .disposed(by: disposeBag)
        
        calendar.rx_displayedMonth
            .asDriver(onErrorJustReturn: "")
            .drive(monthLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Change date and pop the view controller
        calendar.rx_selectedDate
            .distinctUntilChanged()
            .bind(to: selectedDate)
            .disposed(by: disposeBag)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
