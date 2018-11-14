//
//  LoadingViewModel.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/6/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/**
 Merges all isLoadingObservables into one isLoading observable
 
 **Example:**
 # Input isLoadingObservables
  - |--true-----false----------->
  - |-----------true----------false->
  - |--------true------false->
  - |-----------------------------------true----------false->
 # are merged into one observable *isLoading*
  - |--true-------------------false-----true----------false->
 
 **Please Note:**
 *First three input observables overlap each other therefore they are represented with first couple true/false events in isLoading observable, the last input observable does not overlaps with no one therefore is representer as second couple true/false events in isLoading observable*
 
 *Fore more cases look at* **LoadingViewModelTests**
 */
open class LoadingViewModel {
    
    /// Loading observable that has only two "next" events. true for show indicator and false to hide indicator.
    public let isLoading: Observable<Bool>
    
    /// Is loading event count
    private let isLoadingCount = Variable(0)
    
    /// Is Not loading event count
    private let isNotLoadingCount = Variable(0)
    
    /// Dispose Bag
    private let disposeBag = DisposeBag()
    
    /// - Parameter isLoadingObservables: observables that will be used for loading indicator
    public init(_ isLoadingObservables: [Observable<Bool>], mainScheduler: SchedulerType = MainScheduler.instance) {
        
        let isLoadingObservable = Observable.merge(isLoadingObservables)
        
        isLoadingObservable
            .bind(toCount: isLoadingCount, isLoading: true)
            .disposed(by: disposeBag)
        
        isLoadingObservable
            .delay(0.005, scheduler: mainScheduler)
            .bind(toCount: isNotLoadingCount, isLoading: false)
            .disposed(by: disposeBag)
        
        isLoading = Observable
            .combineLatest(isLoadingCount.asObservable(), isNotLoadingCount.asObservable())
            .filter{!($0 == 0 && $1 == 0)} // filter initial setup isLoadingCount/isNotLoadingCount = 0
            .map{$0 > $1}
            .distinctUntilChanged()
            .observeOn(mainScheduler)
            .shareReplay(1)
    }
}

fileprivate extension ObservableType where Self.E == Bool {
    
    /// Bind bool to int count(int) by increasing int with one on each event
    ///
    /// - Parameters:
    ///   - countVariable: Int Variable that will be increased
    ///   - isLoading: flag used for filtering
    /// - Returns: Disposables as result of binding
    func bind(toCount countVariable: Variable<Int>, isLoading: Bool) -> Disposable {
        return
            filter{$0 == isLoading}
            .map{_ in countVariable.value + 1}
            .bind(to: countVariable)
    }
}

public extension ObservableType {
    
    /// Filter stream using loading observable
    ///
    /// - Parameters:
    ///   - loading: flag used to determine the loading sequence life cycle
    /// - Returns: The same observable
    public func waitFor<T>(_ loading: Observable<Bool>) -> Observable<T> where E == T {
        return Observable.combineLatest(self, loading.startWith(false)) { (value: $0, loading: $1) }
            .flatMapLatest { result -> Observable<T> in
                guard !result.loading else {
                    return .never()
                }
                
                return Observable<T>.just(result.value)
        }
    }
}
