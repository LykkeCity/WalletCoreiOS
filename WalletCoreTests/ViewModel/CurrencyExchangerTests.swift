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
        assetPairs: [LWAssetPairModel],
        input: (
            amaunt: Decimal,
            from: LWAssetModel,
            to: LWAssetModel,
            bid: Bool
        ),
        expectedResult: Decimal
    )
    
    func testExchangeBTCUSDAskToUSD() {
        driveOnScheduler(scheduler) { [weak self] in
            self?.exchangeAssert(withData: (
                rates: [
                    LWAssetPairRateModel(json: ["Id": "BTCUSD", "Bid": 6492.006, "Ask": 6526.1])
                ],
                assetPairs: [
                    LWAssetPairModel.assetPair(withDict: ["Id":"BTCUSD","BaseAssetId":"BTC","QuotingAssetId":"USD"])
                ],
                input: (
                    amaunt: Decimal(1.0),
                    from: LWAssetModel(assetId: "BTC"),
                    to: LWAssetModel(assetId: "USD", accuracy: 2),
                    bid: false
                ),
                expectedResult: Decimal(6526.1)
            ))
        }
    }
    
    func testExchangeBTCUSDAskToBTC() {
        driveOnScheduler(scheduler) { [weak self] in
            self?.exchangeAssert(withData: (
                rates: [
                    LWAssetPairRateModel(json: ["Id": "BTCUSD", "Bid": 6492.006, "Ask": 6526.1])
                ],
                assetPairs: [
                    LWAssetPairModel.assetPair(withDict: ["Id":"BTCUSD","BaseAssetId":"BTC","QuotingAssetId":"USD"])
                ],
                input: (
                    amaunt: Decimal(1.0),
                    from: LWAssetModel(assetId: "USD"),
                    to: LWAssetModel(assetId: "BTC", accuracy: 8),
                    bid: false
                ),
                expectedResult: Decimal(0.00015323)
            ))
        }
    }
    
    func testExchangeUSDBTCAskToUSD() {
        driveOnScheduler(scheduler) { [weak self] in
            self?.exchangeAssert(withData: (
                rates: [
                    LWAssetPairRateModel(json: ["Id": "USDBTC", "Bid": 0.00015403, "Ask": 0.00015323])
                ],
                assetPairs: [
                    LWAssetPairModel.assetPair(withDict: ["Id":"USDBTC","BaseAssetId":"USD","QuotingAssetId":"BTC"])
                ],
                input: (
                    amaunt: Decimal(1.0),
                    from: LWAssetModel(assetId: "BTC"),
                    to: LWAssetModel(assetId: "USD", accuracy: 2),
                    bid: false
                ),
                expectedResult: Decimal(6526.14)
            ))
        }
    }
    
    func testExchangeUSDBTCAskToBTC() {
        driveOnScheduler(scheduler) { [weak self] in
            self?.exchangeAssert(withData: (
                rates: [
                    LWAssetPairRateModel(json: ["Id": "USDBTC", "Bid": 0.00015403, "Ask": 0.00015323])
                ],
                assetPairs: [
                    LWAssetPairModel.assetPair(withDict: ["Id":"USDBTC","BaseAssetId":"USD","QuotingAssetId":"BTC"])
                ],
                input: (
                    amaunt: Decimal(1.0),
                    from: LWAssetModel(assetId: "USD"),
                    to: LWAssetModel(assetId: "BTC", accuracy: 8),
                    bid: false
                ),
                expectedResult: Decimal(0.00015323)
            ))
        }
    }
    
    
    func testExchangeBTCUSDBidToUSD() {
        driveOnScheduler(scheduler) { [weak self] in
            self?.exchangeAssert(withData: (
                rates: [
                    LWAssetPairRateModel(json: ["Id": "BTCUSD", "Bid": 6492.006, "Ask": 6526.1])
                ],
                assetPairs: [
                    LWAssetPairModel.assetPair(withDict: ["Id":"BTCUSD","BaseAssetId":"BTC","QuotingAssetId":"USD"])
                ],
                input: (
                    amaunt: Decimal(1.0),
                    from: LWAssetModel(assetId: "BTC"),
                    to: LWAssetModel(assetId: "USD", accuracy: 2),
                    bid: true
                ),
                expectedResult: Decimal(6492.006)
            ))
        }
    }
    
    func testExchangeBTCUSDBidToBTC() {
        driveOnScheduler(scheduler) { [weak self] in
            self?.exchangeAssert(withData: (
                rates: [
                    LWAssetPairRateModel(json: ["Id": "BTCUSD", "Bid": 6492.006, "Ask": 6526.1])
                ],
                assetPairs: [
                    LWAssetPairModel.assetPair(withDict: ["Id":"BTCUSD","BaseAssetId":"BTC","QuotingAssetId":"USD"])
                ],
                input: (
                    amaunt: Decimal(1.0),
                    from: LWAssetModel(assetId: "USD"),
                    to: LWAssetModel(assetId: "BTC", accuracy: 8),
                    bid: true
                ),
                expectedResult: Decimal(0.00015404)
            ))
        }
    }
    
    func testExchangeUSDBTCBidToUSD() {
        driveOnScheduler(scheduler) { [weak self] in
            self?.exchangeAssert(withData: (
                rates: [
                    LWAssetPairRateModel(json: ["Id": "USDBTC", "Bid": 0.00015403, "Ask": 0.00015323])
                ],
                assetPairs: [
                    LWAssetPairModel.assetPair(withDict: ["Id":"USDBTC","BaseAssetId":"USD","QuotingAssetId":"BTC"])
                ],
                input: (
                    amaunt: Decimal(1.0),
                    from: LWAssetModel(assetId: "BTC"),
                    to: LWAssetModel(assetId: "USD", accuracy: 2),
                    bid: true
                ),
                expectedResult: Decimal(6492.24)
            ))
        }
    }
    
    func testExchangeUSDBTCBidToBTC() {
        driveOnScheduler(scheduler) { [weak self] in
            self?.exchangeAssert(withData: (
                rates: [
                    LWAssetPairRateModel(json: ["Id": "USDBTC", "Bid": 0.00015403, "Ask": 0.00015323])
                ],
                assetPairs: [
                    LWAssetPairModel.assetPair(withDict: ["Id":"USDBTC","BaseAssetId":"USD","QuotingAssetId":"BTC"])
                ],
                input: (
                    amaunt: Decimal(1.0),
                    from: LWAssetModel(assetId: "USD"),
                    to: LWAssetModel(assetId: "BTC", accuracy: 8),
                    bid: true
                ),
                expectedResult: Decimal(0.00015403)
            ))
        }
    }
    
    func testExchangeBTCEURAsk() {
        driveOnScheduler(scheduler) { [weak self] in
            self?.exchangeAssert(withData: (
                rates: [
                    LWAssetPairRateModel(json: ["Inverted": true, "Id": "BTCEUR", "Bid": 5553.037, "Ask": 5558.593])
                ],
                assetPairs: [
                    LWAssetPairModel.assetPair(withDict: ["Id":"BTCEUR","BaseAssetId":"BTC","QuotingAssetId":"EUR"])
                ],
                input: (
                    amaunt: Decimal(1.0),
                    from: LWAssetModel(assetId: "BTC"),
                    to: LWAssetModel(assetId: "EUR", accuracy: 2),
                    bid: false
                ),
                expectedResult: Decimal(5558.593)
            ))
        }
    }
    
    func testExchangeBTCEURBid() {
        driveOnScheduler(scheduler) { [weak self] in
            self?.exchangeAssert(withData: (
                rates: [
                    LWAssetPairRateModel(json: ["Inverted": true, "Id": "EURBTC", "Bid": 5553.037, "Ask": 5558.593])
                ],
                assetPairs: [
                    LWAssetPairModel.assetPair(withDict: ["Id":"EURBTC","BaseAssetId":"EUR","QuotingAssetId":"BTC"])
                ],
                input: (
                    amaunt: Decimal(1.0),
                    from: LWAssetModel(assetId: "EUR"),
                    to: LWAssetModel(assetId: "BTC", accuracy: 8),
                    bid: true
                ),
                expectedResult: Decimal(5553.037)
            ))
        }
    }
    
    func testExchangeUSDEURAsk() {
        driveOnScheduler(scheduler) { [weak self] in
            self?.exchangeAssert(withData: (
                rates: [
                    LWAssetPairRateModel(json: ["Id": "USDEUR", "Bid": 1.45, "Ask": 1.35])
                ],
                assetPairs: [
                    LWAssetPairModel.assetPair(withDict: ["Id":"USDEUR","BaseAssetId":"USD","QuotingAssetId":"EUR"])
                ],
                input: (
                    amaunt: Decimal(10.0),
                    from: LWAssetModel(assetId: "USD"),
                    to: LWAssetModel(assetId: "EUR", accuracy: 2),
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
                assetPairs: [
                    LWAssetPairModel.assetPair(withDict: ["Id":"USDEUR","BaseAssetId":"USD","QuotingAssetId":"EUR"])
                ],
                input: (
                    amaunt: Decimal(10.0),
                    from: LWAssetModel(assetId: "USD"),
                    to: LWAssetModel(assetId: "EUR", accuracy: 2),
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
                assetPairs: [
                    LWAssetPairModel.assetPair(withDict: ["Id":"EURUSD","BaseAssetId":"EUR","QuotingAssetId":"USD"])
                ],
                input: (
                    amaunt: Decimal(10.0),
                    from: LWAssetModel(assetId: "USD"),
                    to: LWAssetModel(assetId: "EUR"),
                    bid: true
                ),
                expectedResult: Decimal(string: "6.89655172413793103448275862068965517")!
            ))
        }
    }

    func testExchangeReversedPairEURBTC() {
        driveOnScheduler(scheduler) { [weak self] in
            self?.exchangeAssert(withData: (
                rates: [
                    LWAssetPairRateModel(json: ["Id": "BTCEUR", "Bid": 5740.948, "Ask": 5746.692])
                ],
                assetPairs: [
                    LWAssetPairModel.assetPair(withDict: ["Id": "BTCEUR",
                        "Name": "test BTC/EUR",
                        "Accuracy": 3,
                        "InvertedAccuracy": 8,
                        "BaseAssetId": "BTC",
                        "QuotingAssetId": "EUR"])
                ],
                input: (
                    amaunt: Decimal(1.0),
                    from: LWAssetModel(assetId: "EUR"),
                    to: LWAssetModel(assetId: "BTC"),
                    bid: true
                ),
                expectedResult: Decimal(string: "0.00017418725966512847703898380546209")!
            ))
        }
    }
    
    func exchangeAssert(withData data: TestExchangeData) {
        //1. arrange
        let trigger = scheduler.createColdObservable([next(1, Void())]).asObservable()
        let authManager = LWRxAuthManagerMock(assetPairRates: LWRxAuthManagerAssetPairRatesMock(data: data.rates),
                                              assetPairs: LWRxAuthManagerAssetPairsMock(data: data.assetPairs))
        let currencyExchanger = CurrencyExchanger(refresh: trigger, authManager: authManager)
        
        //2. execute
        let results = scheduler.createObserver(Optional<Decimal>.self)
        
        let subscription = scheduler.createColdObservable([next(2, data)]).asObservable()
            .observeOn(scheduler)
            .flatMap{ element in
                currencyExchanger.exchange(
                    amount: element.input.amaunt,
                    from: element.input.from,
                    to: element.input.to,
                    bid: element.input.bid
                )
            }
            .bind(to: results)
        
        scheduler.scheduleAt(3000) { subscription.dispose() }
        scheduler.start()
        
        let finalResult: String
        let expectedResult: String
        
        if let accuracy = data.input.to.accuracy {
            finalResult = (results.events[0].value.element!?.convertAsCurrency(code: "", symbol: "", accuracy: Int(accuracy)))!
            expectedResult = data.expectedResult.convertAsCurrency(code: "", symbol: "", accuracy: Int(accuracy))
        } else {
            finalResult = (results.events[0].value.element!?.description)!
            expectedResult = data.expectedResult.description
        }
        
        //3. assert
        XCTAssertEqual(finalResult, expectedResult)
    }
}
