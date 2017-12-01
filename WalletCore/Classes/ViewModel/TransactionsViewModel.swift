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
    
    typealias that = TransactionsViewModel
    /// History Transactions
    public let transactions: Driver<[TransactionViewModel]>
    public let transactionsAsCsv: Driver<ApiResult<URL>>
    
    /// Loading indicator
    public let loading: LoadingViewModel

    public init(
        downloadCsv: Observable<Void>,
        currencyExchanger: CurrencyExchanger,
        authManager: LWRxAuthManager = LWRxAuthManager.instance
    ) {
        let transactionsObservable = authManager.history.request()
        
        let transactions = transactionsObservable
            .filterSuccess()
            .map{(transactions: [LWBaseHistoryItemType]) in
                return transactions.map{TransactionViewModel(item: $0, currencyExcancher: currencyExchanger)}
            }
        
        self.transactions = transactions
            .asDriver(onErrorJustReturn: [])
        
        self.transactionsAsCsv = downloadCsv
            .mapToCSVURL(transactions: transactions)
            .asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        
        self.loading = LoadingViewModel([transactionsObservable.isLoading()])
    }
}

fileprivate extension ObservableType where Self.E == Void {
    func mapToCSVURL(transactions: Observable<[TransactionViewModel]>) -> Observable<ApiResult<URL>> {
        guard let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Transactions.csv") else {
            return Observable.just(.error(withData: ["msg": "Can't create file"]))
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
    
    func combineLatest() -> Observable<[(date: String, amountInBase: String, amount: String, title: String)]> {
        return map { (transactions: [TransactionViewModel]) in
            return transactions.map { (viewModel: TransactionViewModel) in
                return Observable.combineLatest(
                    viewModel.date.asObservable(),
                    viewModel.amauntInBase.asObservable(),
                    viewModel.amaunt.asObservable(),
                    viewModel.title.asObservable()
                ) {(
                    date: $0,
                    amauntInBase: $1,
                    amaunt: $2,
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
    func mapToCsvContent() -> Observable<String> {
        return map { (transactions: E) -> String in
            return transactions
                .map{"\($0.title.csvValue),\($0.amount.csvNumberValue),\($0.amountInBase.csvNumberValue),\($0.date.csvValue)\n"}
                .reduce("Title,Amount,Amount in Base Asset,Transaction Date\n") {$0 + $1}
        }
    }
}

fileprivate extension ObservableType where Self.E == String {
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
    
    var csvValue: String {
        return
            replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: ",", with: "")
    }

    var csvNumberValue: String {
        return
            replacingOccurrences(of: "\n", with: " ")
            .removeGroupingSeparator()
            .replaceDecimalSeparator()
    }

}
