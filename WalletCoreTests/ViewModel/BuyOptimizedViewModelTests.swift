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
    private let disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /**
     Turns
     Input:
     |--true-----false----------->
     
     into output
     |--true-----false----------->
     */
    func testSpread() {
        driveOnScheduler(scheduler) {
            
            let tradingViewModel = BuyOptimizedViewModel(trigger: Observable.never(), dependency: (
                currencyExchanger: CurrencyExchangerMock(),
                authManager: LWRxAuthManagerMock()
            ))
            
            scheduler
                .createHotObservable([next(100, (autoUpdated: false, asset: LWAssetModel()))])
                .asObservable()
                .bind(to: tradingViewModel.buyAsset)
                .disposed(by: disposeBag)
            
            scheduler
                .createHotObservable([next(110, true)])
                .asObservable()
                .bind(to: tradingViewModel.bid)
                .disposed(by: disposeBag)

            scheduler
                .createHotObservable([next(120, (autoUpdated: true, value: "12,12"))])
                .asObservable()
                .bind(to: tradingViewModel.buyAmount)
                .disposed(by: disposeBag)
            
            scheduler
                .createHotObservable([next(130, (autoUpdated: false, wallet: LWSpotWallet.factory()))])
                .asObservable()
                .bind(to: tradingViewModel.payWithWallet)
                .disposed(by: disposeBag)
            
            let results = scheduler.createObserver(String.self)
            let subscription = tradingViewModel.spreadAmount.drive(results)
            
            scheduler.scheduleAt(3000) { subscription.dispose() }
            scheduler.start()
            
            let events = results.events
            let das = 123
            
            //1. arrange
//            let isLoadingObservable = scheduler.createHotObservable([
//                next(100, true),
//                next(200, false)
//                ]).asObservable()
//
//            let viewModel = LoadingViewModel([isLoadingObservable], mainScheduler: scheduler)
//
//            //2. execute
//            let results = scheduler.createObserver(Bool.self)
//            let subscription = viewModel.isLoading.subscribeOn(scheduler).bind(to: results)
//
//            scheduler.scheduleAt(3000) { subscription.dispose() }
//            scheduler.start()
//
//            XCTAssertEqual(results.events[0].time, 100)
//            XCTAssertTrue(results.events[0].value.element!)
//
//            XCTAssertEqual(results.events[1].time, 201)
//            XCTAssertFalse(results.events[1].value.element!)
        }
    }
}

fileprivate extension LWSpotWallet {
    static func factory() ->  LWSpotWallet{
        let wallet = LWSpotWallet()
        wallet.asset = LWAssetModel(assetId: "USD")
        
        return wallet
    }
}
