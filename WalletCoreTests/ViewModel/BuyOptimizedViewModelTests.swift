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
        pairModels: [LWAssetPairRateModel],
        baseAsset: LWAssetModel,
        buyAsset: LWAssetModel,
        payWithWallet: LWSpotWallet,
        bid: Bool,
        buyAmount: String,
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
    
    func testSpread() {
        driveOnScheduler(scheduler) {[weak self] in
            self?.assertSpread(withData: (
                pairModels: [LWAssetPairRateModel(json: ["Id": "USDEUR", "Bid": 2, "Ask": 3])!],
                baseAsset: LWAssetModel(assetId: "USD"),
                buyAsset: LWAssetModel(assetId: "EUR"),
                payWithWallet: LWSpotWallet(assetId: "USD"),
                bid: true,
                buyAmount: "12",
                expectedResult: "4"
            ))
        }
    }
    
    func testSpreadWithReversedPair() {
        driveOnScheduler(scheduler) {[weak self] in
            self?.assertSpread(withData: (
                pairModels: [LWAssetPairRateModel(json: ["Id": "EURUSD", "Bid": 2, "Ask": 3])!],
                baseAsset: LWAssetModel(assetId: "USD"),
                buyAsset: LWAssetModel(assetId: "EUR"),
                payWithWallet: LWSpotWallet(assetId: "USD"),
                bid: true,
                buyAmount: "12",
                expectedResult: "24"
            ))
        }
    }
    
    func testSpreadWithReversedPair2() {
        driveOnScheduler(scheduler) {[weak self] in
            self?.assertSpread(withData: (
                pairModels: [
                    LWAssetPairRateModel(json: ["Id": "EURUSD", "Bid": 2, "Ask": 3])!,
                    LWAssetPairRateModel(json: ["Id": "BTCEUR", "Bid": 2, "Ask": 3])!
                ],
                baseAsset: LWAssetModel(assetId: "USD"),
                buyAsset: LWAssetModel(assetId: "EUR"),
                payWithWallet: LWSpotWallet(assetId: "USD"),
                bid: true,
                buyAmount: "12",
                expectedResult: "24"
            ))
        }
    }
    
    func assertSpread(withData data: TestData) {

        let trigger = scheduler.createHotObservable([next(0, Void())]).asObservable()
        let authManager = LWRxAuthManagerMock(
            baseAsset: LWRxAuthManagerBaseAssetMock(asset: data.baseAsset),
            assetPairRates: LWRxAuthManagerAssetPairRatesMock(data: data.pairModels)
        )
        
        let currencyExchanger = CurrencyExchanger(refresh: trigger, authManager: authManager)
        
        let tradingViewModel = BuyOptimizedViewModel(trigger: Observable.never(), dependency: (
            currencyExchanger: currencyExchanger,
            authManager: authManager
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
            .createHotObservable([next(120, (autoUpdated: true, value: data.buyAmount))])
            .asObservable()
            .bind(to: tradingViewModel.buyAmount)
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
        
        XCTAssertEqual(results.events.first!.value.element!, data.expectedResult)
    }
}
