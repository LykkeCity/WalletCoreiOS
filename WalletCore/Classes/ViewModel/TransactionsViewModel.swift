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
    
    public enum SortType {
        case asc
        case desc
    }
    
    typealias that = TransactionsViewModel
    
    /// History Transactions
    public let transactions: Driver<[TransactionViewModel]>
    
    /// Transactions represented as CSV
    public let transactionsAsCsv: Driver<ApiResult<URL>>
    
    /// Once the value of this Variable is changed there will be created an event with sorted TransactionsViewModel.transactions according SortType
    public let sortBy = Variable<SortType>(SortType.asc)
    
    /// Loading indicator
    public let loading: LoadingViewModel
    
    /// Transaction models fetched from the API
    private let transactionModels = Variable<[LWBaseHistoryItemType]>([])

    private let disposeBag = DisposeBag()
    
    public init(
        downloadCsv: Observable<Void>,
        currencyExchanger: CurrencyExchanger,
        authManager: LWRxAuthManager = LWRxAuthManager.instance
    ) {
        let transactionsObservable = authManager.history.request()
        
        transactionsObservable
            .filterSuccess()
            .bind(to: transactionModels)
            .disposed(by: disposeBag)
        
        //Reorder transactionModels according sortBy events
        sortBy.asObservable()
            .skip(1) // skip initial value
            .sort(models: transactionModels)
            .bind(to: transactionModels)
            .disposed(by: disposeBag)
        
        let transactions = transactionModels.asObservable()
            .mapToViewModels(currencyExchanger: currencyExchanger)
        
        self.transactions = transactions
            .asDriver(onErrorJustReturn: [])
        
        self.transactionsAsCsv = downloadCsv
            .mapToCSVURL(transactions: transactions)
            .asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        
        self.loading = LoadingViewModel([
            transactionsObservable.isLoading(),
            self.transactionsAsCsv.isLoading().asObservable()
        ])
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
                sortBy.isAsc ? first.dateTime > second.dateTime : first.dateTime < second.dateTime
            }
        }
    }
}

fileprivate extension ObservableType where Self.E == [LWBaseHistoryItemType] {
    
    /// Map collection of LWBaseHistoryItemType to collection of TransactionViewModel
    ///
    /// - Parameter currencyExchanger: CurrencyExchanger required by TransactionViewModel
    /// - Returns: Observable of collection of TransactionViewModel
    func mapToViewModels(currencyExchanger: CurrencyExchanger) -> Observable<[TransactionViewModel]> {
        return map{(transactions: [LWBaseHistoryItemType]) in
            return transactions.map{TransactionViewModel(item: $0, currencyExcancher: currencyExchanger)}
        }
    }
}

fileprivate extension ObservableType where Self.E == Void {
    
    /// Map collection of TransactionViewModel to URL to generated CSV file
    ///
    /// - Parameter transactions: Transactions which will be included in the produced CSV file
    /// - Returns: Observable of ApiResult of URL
    func mapToCSVURL(transactions: Observable<[TransactionViewModel]>) -> Observable<ApiResult<URL>> {
        guard let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Transactions.csv") else {
            return Observable
                .just(.error(withData: ["msg": "Can't create file"]))
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
                .map{"\($0.title.csvValue),\($0.amount.csvNumberValue),\($0.amountInBase.csvNumberValue),\($0.date.csvValue)\n"}
                .reduce("Title,Amount,Amount in Base Asset,Transaction Date\n") {$0 + $1}
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

public extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, Self.E == ApiResult<URL> {
    public func filterSuccess() -> Driver<URL> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Driver<Bool> {
        return map{$0.isLoading}
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
