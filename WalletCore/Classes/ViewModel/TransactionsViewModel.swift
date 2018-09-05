//
//  TransactionsViewModel.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/11/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class TransactionsViewModel {
    
    public typealias Dependency = (
        currencyExcancher: CurrencyExchanger,
        authManager: LWRxAuthManager,
        formatter: TransactionFormatterProtocol
    )
    
    public enum SortType {
        case asc
        case desc
    }
    
    typealias that = TransactionsViewModel
    
    /// History Transactions
    public let transactions: Driver<[TransactionViewModel]>
    
    /// Transactions represented as CSV
    public var transactionsAsCsv: Observable<ApiResult<URL>>
    
    public let presentEmptyWallet: Driver<Void>
    
    /// Once the value of this Variable is changed there will be created an event with sorted TransactionsViewModel.transactions according SortType
    public let sortBy = Variable<SortType>(SortType.asc)
    
    /// Filter transactions by title
    public let filter = Variable<String?>(nil)
    
    /// Filter view model
    public let filterViewModel: TransactionFilterViewModel
    
    /// Loading indicator
    public let loading: LoadingViewModel
    
    /// Transaction models fetched from the API
    private let transactionModels = Variable<[LWBaseHistoryItemType]>([])
    
    private let transactionsToDisplay = Variable<[LWBaseHistoryItemType]>([])
    
    //enable download buttons
    public var isDownloadButtonEnabled: Driver<Bool>
   
    public let errors: Driver<[AnyHashable: Any]>
    
    private let disposeBag = DisposeBag()
    
    public init(downloadCsv: Observable<Void>, dependency: Dependency) {
        
        filterViewModel = TransactionFilterViewModel(formatter: TransactionFilterFormatter.instance)
        
        let transactionsObservable = dependency.authManager.history.request()
        
        let transactions = transactionsToDisplay.asObservable()
            .skip(1) // skip initial empty array
            .map{ $0.map{ TransactionViewModel(item: $0, dependency: dependency) } }
        
        self.transactions = transactions
            .asDriver(onErrorJustReturn: [])
        
        self.presentEmptyWallet = self.transactions
            .filter{ $0.isEmpty }
            .map{ _ in () }
        
        self.transactionsAsCsv = downloadCsv
            .mapToCSVURL(transactions: transactions)
            .observeOn(MainScheduler.instance)
            .catchErrorJustReturn(ApiResult.error(withData: ["Message": Localize("errors.server.problems")]))
            .share()
        
        errors = transactionsAsCsv
            .filterError()
            .asDriver(onErrorJustReturn: [:])
        
        self.loading = LoadingViewModel([
            transactionsObservable.isLoading(),
            self.transactionsAsCsv.asObservable().isLoading()
        ])
        
        transactionModels.asObservable()
            .bind(to: transactionsToDisplay)
            .disposed(by: disposeBag)
        
        isDownloadButtonEnabled = transactionsToDisplay.asDriver()
            .map{ !$0.isEmpty }
     
        //Reorder transactionModels according sortBy events
        sortBy.asObservable()
            .skip(1) // skip initial value
            .sort(models: transactionsToDisplay)
            .bind(to: transactionsToDisplay)
            .disposed(by: disposeBag)
        
        filter.asObservable()
            .filterNil()
            .map{ [transactionModels] filter in
                guard filter.isNotEmpty else {
                    return transactionModels.value
                }
                
                return transactionModels.value.filter {
                    [$0.displayName].contains{ $0.localizedCaseInsensitiveContains(filter) }
                }
            }
            .bind(to: transactionsToDisplay)
            .disposed(by: disposeBag)
        
        filterViewModel.filterDatePair.asObservable()
            .map { [transactionModels] range in
                return transactionModels.value.filter { transaction in
                    // Strip the clock values from the transaction date
                    let components = Calendar.current.dateComponents([.day, .month, .year], from: transaction.dateTime)
                    guard let transactionDate = Calendar.current.date(from: components) else { return false }
                    switch (range.start, range.end) {
                    case (.some(let startValue), .some(let endValue)) where startValue <= endValue:
                        return startValue <= transactionDate && endValue >= transactionDate
                    case (.some(let startValue), .some(let endValue)) where startValue > endValue:
                        return startValue >= transactionDate && endValue <= transactionDate
                    case (.none, .some(let endValue)):
                        return endValue >= transactionDate
                    case (.some(let startValue), .none):
                        return startValue <= transactionDate
                    default:
                        return true
                    }
                }
            }
            .bind(to: transactionsToDisplay)
            .disposed(by: disposeBag)
        
        transactionsObservable
            .filterSuccess()
            .bind(to: transactionModels)
            .disposed(by: disposeBag)
    }
}

fileprivate extension ObservableType where Self.E == TransactionsViewModel.SortType {
    
    /// Sort given collection of LWBaseHistoryItemType by current SortType
    ///
    /// - Parameter models: Collection that has to be sorted
    /// - Returns: Observable of sorted collection
    func sort(models: Variable<[LWBaseHistoryItemType]>) -> Observable<[LWBaseHistoryItemType]>  {
        return map{ sortBy -> [LWBaseHistoryItemType] in
            models.value.sorted{ first, second in
                guard let firstDate = first.dateTime, let secondDateTime = second.dateTime else {
                    return false
                }
                
                return sortBy.isAsc ? firstDate > secondDateTime : firstDate < secondDateTime
            }
        }
    }
}

public extension ObservableType where Self.E == Void {
    
    /// Map collection of TransactionViewModel to URL to generated CSV file
    ///
    /// - Parameter transactions: Transactions which will be included in the produced CSV file
    /// - Returns: Observable of ApiResult of URL
    func mapToCSVURL(transactions: Observable<[TransactionViewModel]>) -> Observable<ApiResult<URL>> {
        guard let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Transactions.csv") else {
            return Observable
                .just(.error(withData: ["Message": Localize("errors.server.problems")]))
                .startWith(.loading)
        }
        
        let csvObservable = transactions
            .combineLatest()
            .mapToCsvContent()
            .mapToUrl(path: path)
            .startWith(.loading)
            .take(2) //if omitted there will be alert on each second to download csv!
        
        return flatMapLatest{csvObservable}
    }
}

fileprivate extension ObservableType where Self.E == [TransactionViewModel] {
    
    /// Map collection of TransactionViewModel to array of tuples
    ///
    /// - Returns: Observable of array of tuples
    func combineLatest() -> Observable<[(date: String, amountInBase: String, amount: String, title: String)]> {
        return map { (transactions: [TransactionViewModel]) in
            return transactions.map { (viewModel: TransactionViewModel) in
                return Observable.combineLatest(
                    viewModel.date.asObservable(),
                    viewModel.amountInBase.asObservable(),
                    viewModel.amount.asObservable(),
                    viewModel.title.asObservable()
                ) {(
                    date: $0,
                    amountInBase: $1,
                    amount: $2,
                    title: $3
                )}
            }
        }
        .flatMap { (data: [Observable<(date: String, amountInBase: String, amount: String, title: String)>]) in
            return Observable.combineLatest(data)
        }
    }
}

fileprivate extension ObservableType where Self.E == [(date: String, amountInBase: String, amount: String, title: String)] {
    
    /// Map array of tuples to a csv string
    ///
    /// - Returns: Observable of string that represents a CSV
    func mapToCsvContent() -> Observable<String> {
        return map { (transactions: E) -> String in
            return transactions
                .map{"\($0.title.csvValue),\($0.amount.csvNumberValue),\($0.date.csvValue)\n"}
                .reduce("Title,Amount,Transaction Date\n") {$0 + $1}
        }
    }
}

fileprivate extension ObservableType where Self.E == String {
    
    /// Map CSV to a URL
    ///
    /// - Parameter path: Target URL
    /// - Returns: ApiResult of writen CSV content URL
    func mapToUrl(path: URL) -> Observable<ApiResult<URL>> {
        return map{content -> ApiResult<URL> in
            do {
                try content.write(to: path, atomically: true, encoding: String.Encoding.utf8)
                return .success(withData: path)
            } catch {
                return .error(withData: ["error": error])
            }
        }
    }
}

fileprivate extension String {
    
    /// Escaping CSV value special characters
    var csvValue: String {
        return
            replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: ",", with: "")
    }

    
    /// Escaping CSV number value special characters
    var csvNumberValue: String {
        return
            replacingOccurrences(of: "\n", with: " ")
            .removeGroupingSeparator()
            .replaceDecimalSeparator()
    }
}

public extension TransactionsViewModel.SortType {
    var isAsc: Bool {
        guard case .asc = self else {return false}
        return true
    }
    
    /// Gets the oposite sorting.
    /// E.g if self is ask will return desc and vice versa
    var reversed: TransactionsViewModel.SortType {
        return isAsc ? .desc : .asc
    }
}
