//
//  BuyOptimizedViewModelTests.swift
//  WalletCoreTests
//
//  Created by Georgi Stanev on 3.01.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import WalletCore

class BuyOptimizedViewModelTests: XCTestCase {

    var scheduler: TestScheduler!
    private var disposeBag = DisposeBag()

    typealias TestData = (
        pairRateModels: [LWAssetPairRateModel],
        pairModels: [LWAssetPairModel],
        baseAsset: LWAssetModel,
        buyAsset: LWAssetModel,
        payWithWallet: LWSpotWallet,
        bid: Bool,
        expectedResult: String
    )

    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSpread1() {
        driveOnScheduler(scheduler) {[weak self] in

            self?.assertSpread(withData: (
                pairRateModels: [LWAssetPairRateModel(json: ["Id": "BTCUSD", "Bid": 13600, "Ask": 13800])!,
                                 LWAssetPairRateModel(json: ["Id": "BTCAUD", "Bid": 14600, "Ask": 14900])!,
                                 LWAssetPairRateModel(json: ["Id": "USDAUD", "Bid": 1.1, "Ask": 1.2])!
                ],
                pairModels: [LWAssetPairModel.assetPair(withDict: ["Id": "BTCUSD", "BaseAssetId": "BTC", "QuotingAssetId": "USD"])!,
                             LWAssetPairModel.assetPair(withDict: ["Id": "BTCAUD", "BaseAssetId": "BTC", "QuotingAssetId": "AUD"])!,
                             LWAssetPairModel.assetPair(withDict: ["Id": "USDAUD", "BaseAssetId": "USD", "QuotingAssetId": "AUD"])!],
                baseAsset: LWAssetModel(json: ["Id": "AUD", "DisplayId": "AUD"]),
                buyAsset: LWAssetModel(assetId: "BTC"),
                payWithWallet: LWSpotWallet(assetId: "USD"),
                bid: true,
                expectedResult: "200 (~230)"
            ))
        }
    }
    func testSpread2() {
        driveOnScheduler(scheduler) {[weak self] in

            self?.assertSpread(withData: (
                pairRateModels: [LWAssetPairRateModel(json: ["Id": "BTCUSD", "Bid": 13600, "Ask": 13800])!,
                             LWAssetPairRateModel(json: ["Id": "BTCAUD", "Bid": 14600, "Ask": 14900])!,
                             LWAssetPairRateModel(json: ["Id": "USDAUD", "Bid": 1.1, "Ask": 1.2])!
                ],
                pairModels: [LWAssetPairModel.assetPair(withDict: ["Id": "BTCUSD", "BaseAssetId": "BTC", "QuotingAssetId": "USD"])!,
                             LWAssetPairModel.assetPair(withDict: ["Id": "BTCAUD", "BaseAssetId": "BTC", "QuotingAssetId": "AUD"])!,
                             LWAssetPairModel.assetPair(withDict: ["Id": "USDAUD", "BaseAssetId": "USD", "QuotingAssetId": "AUD"])!],
                baseAsset: LWAssetModel(json: ["Id": "AUD", "DisplayId": "AUD"]),
                buyAsset: LWAssetModel(assetId: "USD"),
                payWithWallet: LWSpotWallet(assetId: "BTC"),
                bid: true,
                expectedResult: "200 (~230)"
            ))
        }
    }

    func testSpread3() {
        driveOnScheduler(scheduler) {[weak self] in

            self?.assertSpread(withData: (
                pairRateModels: [LWAssetPairRateModel(json: ["Id": "BTCUSD", "Bid": 13600, "Ask": 13800])!,
                                 LWAssetPairRateModel(json: ["Id": "BTCAUD", "Bid": 14600, "Ask": 14900])!,
                                 LWAssetPairRateModel(json: ["Id": "USDAUD", "Bid": 1.1, "Ask": 1.2])!
                ],
                pairModels: [LWAssetPairModel.assetPair(withDict: ["Id": "BTCUSD", "BaseAssetId": "BTC", "QuotingAssetId": "USD"])!,
                             LWAssetPairModel.assetPair(withDict: ["Id": "BTCAUD", "BaseAssetId": "BTC", "QuotingAssetId": "AUD"])!,
                             LWAssetPairModel.assetPair(withDict: ["Id": "USDAUD", "BaseAssetId": "USD", "QuotingAssetId": "AUD"])!],
                baseAsset: LWAssetModel(json: ["Id": "USD", "DisplayId": "USD"]),
                buyAsset: LWAssetModel(assetId: "USD"),
                payWithWallet: LWSpotWallet(assetId: "BTC"),
                bid: true,
                expectedResult: "200"
            ))
        }
    }

    func assertSpread(withData data: TestData) {

        let trigger = scheduler.createHotObservable([next(0, Void())]).asObservable()
        let authManager = LWRxAuthManagerMock(
            baseAsset: LWRxAuthManagerBaseAssetMock(asset: data.baseAsset),
            assetPairRates: LWRxAuthManagerAssetPairRatesMock(data: data.pairRateModels),
            assetPairs: LWRxAuthManagerAssetPairsMock(data: data.pairModels)
        )

        let currencyExchanger = CurrencyExchanger(refresh: trigger, authManager: authManager)

        let tradingViewModel = BuyOptimizedViewModel(trigger: Observable.never(), dependency: (
            currencyExchanger: currencyExchanger,
            authManager: authManager,
            spreadService: SpreadService()
        ))

        scheduler
            .createHotObservable([next(100, (autoUpdated: false, asset: data.buyAsset))])
            .asObservable()
            .bind(to: tradingViewModel.buyAsset)
            .disposed(by: disposeBag)

        scheduler
            .createHotObservable([next(110, data.bid)])
            .asObservable()
            .bind(to: tradingViewModel.bid)
            .disposed(by: disposeBag)

        scheduler
            .createHotObservable([next(130, (autoUpdated: false, wallet: data.payWithWallet))])
            .asObservable()
            .bind(to: tradingViewModel.payWithWallet)
            .disposed(by: disposeBag)

        let results = scheduler.createObserver(String.self)

        let subscription = tradingViewModel.spreadAmount.drive(results)

        scheduler.scheduleAt(3000) { subscription.dispose() }
        scheduler.start()

        XCTAssertEqual(results.events.last?.value.element, data.expectedResult)
    }

}
