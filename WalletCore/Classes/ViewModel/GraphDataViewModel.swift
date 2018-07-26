//
//  GraphDataViewModel.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/11/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class GraphDataViewModel {
    typealias That = GraphDataViewModel

    public var buy: Driver<String>
    public var sell: Driver<String>
    public var buyGraph: Driver<String>
    public var sellGraph: Driver<String>
    public var cryptoCurrency: Driver<String>

    /// Loading indicator
    public var loading: Observable<Bool>

    public var periodArray: Observable<[LWGraphPeriodModel]>
    public var graphData: Observable<LWPacketGraphData>
    public var assetPairData: Observable<LWAssetPairRateModel>

    public var selectedPeriod: Variable<LWGraphPeriodModel?>

    public var assetPairModel: LWAssetPairModel
    public var graphViewPoints: Int32

    private let disposeBag = DisposeBag()

    public init(
        assetPairModel: LWAssetPairModel,
        graphViewPoints: Int32,
        authManager: LWRxAuthManager = LWRxAuthManager.instance,
        keyChainManager: LWKeychainManager = LWKeychainManager.instance()
    ) {

        let selectedPeriod = Variable<LWGraphPeriodModel?>(nil)
        let selectedPeriodObservable = selectedPeriod
            .asObservable()
            .distinctUntilChanged { $0 == $1 }
            .shareReplay(1)

        self.selectedPeriod = selectedPeriod
        self.assetPairModel = assetPairModel
        self.graphViewPoints = graphViewPoints

        let intervalObservable = That.getIntervalObservable(keyChainManager: keyChainManager)

        self.assetPairData = intervalObservable
            .flatMap {_ in authManager.assetPairRate.request(withParams: assetPairModel.identity)}
            .filterSuccess()
            .shareReplay(1)

        let requestGraphPeriodsObservable = authManager.graphPeriods.request()

        self.periodArray = requestGraphPeriodsObservable
            .filterSuccess()
            .map {$0.periods as? [LWGraphPeriodModel]}
            .filterNil()

        requestGraphPeriodsObservable
            .bind(toSelectedPeriod: selectedPeriod)
            .disposed(by: disposeBag)

        let graphDataObservable = Observable.of(
            intervalObservable.mapTo(periodModel: selectedPeriod.value),
            selectedPeriodObservable.mapToTuple()
        )
        .merge()
        .flatMapToGraphData(withAssetPair: assetPairModel, graphViewPoints: graphViewPoints, authManager: authManager)
        .shareReplay(1)

        self.loading = graphDataObservable.isLoading()
        self.graphData = graphDataObservable.filterSuccess()

        self.buy = assetPairData
            .map {$0.ask}
            .mapToNumber(withAssetPair: assetPairModel)
            .asDriver(onErrorJustReturn: "")

        self.sell = assetPairData
            .map {$0.bid}
            .mapToNumber(withAssetPair: assetPairModel)
            .asDriver(onErrorJustReturn: "")

        self.buyGraph = assetPairData
            .map {$0.ask}
            .mapToGraphNumber(withAssetPair: assetPairModel)
            .asDriver(onErrorJustReturn: "")

        self.sellGraph = assetPairData
            .map {$0.bid}
            .mapToGraphNumber(withAssetPair: assetPairModel)
            .asDriver(onErrorJustReturn: "")

        self.cryptoCurrency = assetPairData
            .mapToCryptoCurrency()
            .asDriver(onErrorJustReturn: "")
    }

    private static func getIntervalObservable(keyChainManager: LWKeychainManager) -> Observable<Int> {
        return Observable<Int>
            .interval(5, scheduler: MainScheduler.instance)
            .startWith(0)
            .skipWhile {_ in !keyChainManager.isAuthenticated}
            .shareReplay(1)
    }
}

fileprivate extension ObservableType where Self.E == ApiResult<LWPacketGraphPeriods> {
    func bind(toSelectedPeriod selectedPeriod: Variable<LWGraphPeriodModel?>) -> Disposable {
        return filterSuccess()
            .map {$0.lastSelectedPeriod}
            .filterNil()
            .bind(to: selectedPeriod)
    }
}

fileprivate extension ObservableType where Self.E == NSNumber? {
    func mapToNumber(withAssetPair assetPair: LWAssetPairModel) -> Observable<String> {
        return filterNil()
            .map {LWUtils.formatFairVolume(
                $0.doubleValue,
                accuracy: Int32(assetPair.accuracy.intValue),
                roundToHigher: true
            )}
            .filterNil()
            .map {$0.replacingOccurrences(of: " ", with: "")}
            .map {$0.appending(" " + assetPair.quotingAssetId)}
            .startWith("")
    }

    func mapToGraphNumber(withAssetPair assetPair: LWAssetPairModel) -> Observable<String> {
        return filterNil()
            .map {LWUtils.formatFairVolume(
                $0.doubleValue,
                accuracy: Int32(assetPair.accuracy.intValue),
                roundToHigher: true
            )}
            .filterNil()
            .map {$0.replacingOccurrences(of: " ", with: "")}
            .startWith("")
    }
}

fileprivate extension ObservableType where Self.E == LWAssetPairRateModel {
    func mapToCryptoCurrency() -> Observable<String> {
        return map {$0.identity}
            .filterNil()
            .startWith("")
    }
}

fileprivate extension ObservableType where Self.E == Int {
    func mapTo(periodModel: LWGraphPeriodModel?) -> Observable<(period: LWGraphPeriodModel, interval: Bool)> {
        return map {_ in periodModel.value}
            .filterNil()
            .map {(period: $0, interval: true)}
    }
}

fileprivate extension ObservableType where Self.E == LWGraphPeriodModel? {
    func mapToTuple() -> Observable<(period: LWGraphPeriodModel, interval: Bool)> {
        return filterNil().map {(period: $0, interval: false)}
    }
}

fileprivate extension ObservableType where Self.E == (period: LWGraphPeriodModel, interval: Bool) {
    func flatMapToGraphData(
        withAssetPair assetPair: LWAssetPairModel,
        graphViewPoints: Int32,
        authManager: LWRxAuthManager
    ) -> Observable<(apiResult: ApiResult<LWPacketGraphData>, interval: Bool)> {
        return flatMap {selectedPeriod in
            return authManager.graphData.request(withParams: (
                period: selectedPeriod.period,
                assetPairId: assetPair.identity,
                points: graphViewPoints
            ))
            .map {(apiResult: $0, interval: selectedPeriod.interval)}
        }
    }
}
