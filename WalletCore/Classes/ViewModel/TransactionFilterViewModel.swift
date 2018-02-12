//
//  TransactionFilterViewModel.swift
//  AFNetworking
//
//  Created by Lyubomir Marinov on 6.02.18.
//

import Foundation
import RxSwift
import RxCocoa

open class TransactionFilterViewModel {
    
    /// Starting date to filter (X < transaction dates)
    public let startDate = Variable<Date?>(nil)
    
    /// End date to filter (transaction dates < X)
    public let endDate = Variable<Date?>(nil)
    
    /// Update the `from` button's title
    public let startButton: Driver<String>
    
    /// Update the `to` button's title
    public let endButton: Driver<String>
    
    /// Filter date pair
    public let filterDatePair = PublishSubject<(start: Date?, end: Date?)>()
    
    /// Filter description string
    public let filterDescription: Driver<NSAttributedString>
    
    private let disposeBag = DisposeBag()
    
    public init(formatter: TransactionFilterFormatterProtocol) {
        
        let startDateObservable = startDate.asObservable().share()
        let endDateObservable = endDate.asObservable().share()
        let filterDatePairObservable = filterDatePair.asObservable().share()

        self.startButton = startDateObservable
            .mapDate(withFormatter: formatter)
            .asDriver(onErrorJustReturn: "")
        
        self.endButton = endDateObservable
            .mapDate(withFormatter: formatter)
            .asDriver(onErrorJustReturn: "")

        self.filterDescription = filterDatePair.asObservable()
            .mapCombination(withFormatter: formatter)
            .asDriver(onErrorJustReturn: NSAttributedString(string: ""))
        
        // update the `startDate` and `endDate` Variables depending on the date pair
        filterDatePairObservable
            .map({ $0.start })
            .bind(to: startDate)
            .disposed(by: disposeBag)
        
        filterDatePairObservable
            .map({ $0.end })
            .bind(to: endDate)
            .disposed(by: disposeBag)
    }
}

public extension ObservableType where Self.E == Date? {
    func mapDate(withFormatter formatter: TransactionFilterFormatterProtocol) -> Observable<String> {
        return map { value in
            guard let date = value else { return "Select date" }
            
            return formatter.formatUIElement(withDate: date, andFormat: "MMM d, yyyy")
        }
    }
}

public extension ObservableType where Self.E == (start: Date?, end: Date?) {
    func mapCombination(withFormatter formatter: TransactionFilterFormatterProtocol) -> Observable<NSAttributedString> {
        return map { value in
            
            let descriptionKeyAttributes: [String: Any] = [
                NSForegroundColorAttributeName: UIColor.white,
                NSFontAttributeName: UIFont(name: "Geomanist-Light", size: 12.0) ?? UIFont.systemFont(ofSize: 12.0)
            ]
            let descriptionValueAttributes: [String: Any] = [
                NSForegroundColorAttributeName: UIColor.white,
                NSFontAttributeName: UIFont(name: "Geomanist", size: 12.0) ?? UIFont.systemFont(ofSize: 12.0)
            ]
            
            let description = NSMutableAttributedString()
            
            if let start = value.start.value {
                let startKey = NSAttributedString(string: "From ",
                                                  attributes: descriptionKeyAttributes)
                let startValue = NSAttributedString(string: formatter.formatUIElement(withDate: start,
                                                                                      andFormat: "dd.MM.yyyy"),
                                                    attributes: descriptionValueAttributes)
                description.append(startKey)
                description.append(startValue)
            }
            if let end = value.end.value {
                let endKey = NSAttributedString(string: "To ",
                                                attributes: descriptionKeyAttributes)
                let endValue = NSAttributedString(string: formatter.formatUIElement(withDate: end,
                                                                                    andFormat: "dd.MM.yyyy"),
                                                  attributes: descriptionValueAttributes)
                description.append(endKey)
                description.append(endValue)
            }
            
            return description
        }
    }
}
