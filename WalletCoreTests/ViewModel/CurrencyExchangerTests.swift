//
//  CurrencyExchangerTests.swift
//  WalletCoreTests
//
//  Created by Georgi Stanev on 4.01.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import WalletCore

class CurrencyExchangerTests: XCTestCase {
    
    var scheduler: TestScheduler!
    private let disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    typealias TestExchangeData = (
        rates: [LWAssetPairRateModel],
        input: (
            amaunt: Decimal,
            from: LWAssetModel,
            to: LWAssetModel,
            bid: Bool
        ),
        expectedResult: Decimal
    )
    
    func testExchangeUSDEURAsk() {
        driveOnScheduler(scheduler) { [weak self] in
            self?.exchangeAssert(withData: (
                rates: [
                    LWAssetPairRateModel(json: ["Id": "USDEUR", "Bid": 1.45, "Ask": 1.35])
                ],
                input: (
                    amaunt: Decimal(10.0),
                    from: LWAssetModel(assetId: "USD"),
                    to: LWAssetModel(assetId: "EUR"),
                    bid: false
                ),
                expectedResult: Decimal(13.5)
            ))
        }
    }
    
    func testExchangeUSDEURBid() {
        driveOnScheduler(scheduler) { [weak self] in
            self?.exchangeAssert(withData: (
                rates: [
                    LWAssetPairRateModel(json: ["Id": "USDEUR", "Bid": 1.45, "Ask": 1.35])
                ],
                input: (
                    amaunt: Decimal(10.0),
                    from: LWAssetModel(assetId: "USD"),
                    to: LWAssetModel(assetId: "EUR"),
                    bid: true
                ),
                expectedResult: Decimal(14.5)
            ))
        }
    }
    
    func testExchangeReversedPair() {
        driveOnScheduler(scheduler) { [weak self] in
            self?.exchangeAssert(withData: (
                rates: [
                    LWAssetPairRateModel(json: ["Id": "EURUSD", "Bid": 1.45, "Ask": 1.35])
                ],
                input: (
                    amaunt: Decimal(10.0),
                    from: LWAssetModel(assetId: "USD"),
                    to: LWAssetModel(assetId: "EUR"),
                    bid: true
                ),
                expectedResult: Decimal(string: "7.4074074074074074074074074074074074")!
            ))
        }
    }
    
    func exchangeAssert(withData data: TestExchangeData) {
        //1. arrange
        let trigger = scheduler.createColdObservable([next(1, Void())]).asObservable()
        let authManager = LWRxAuthManagerMock(assetPairRates: LWRxAuthManagerAssetPairRatesMock(data: data.rates))
        let currencyExchanger = CurrencyExchanger(refresh: trigger, authManager: authManager)
        
        //2. execute
        let results = scheduler.createObserver(Optional<Decimal>.self)
        
        let subscription = scheduler.createColdObservable([next(2, data)]).asObservable()
            .observeOn(scheduler)
            .flatMap{ element in
                currencyExchanger.exchange(
                    amaunt: element.input.amaunt,
                    from: element.input.from,
                    to: element.input.to,
                    bid: element.input.bid
                )
            }
            .bind(to: results)
        
        scheduler.scheduleAt(3000) { subscription.dispose() }
        scheduler.start()
        
        //3. assert
        XCTAssertEqual(results.events[0].value.element!, data.expectedResult)
    }
}
