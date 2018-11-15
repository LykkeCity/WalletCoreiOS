//
//  LoadingViewModelTests.swift
//  WalletCore
//
//  Created by Georgi Stanev on 8/24/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import WalletCore

class LoadingViewModelTests: XCTestCase {
    
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
    func testSingleObservable() {
        driveOnScheduler(scheduler) {
            //1. arrange
            let isLoadingObservable = scheduler.createHotObservable([
                next(100, true),
                next(200, false)
            ]).asObservable()
            
            let viewModel = LoadingViewModel([isLoadingObservable], mainScheduler: scheduler)
            
            //2. execute
            let results = scheduler.createObserver(Bool.self)
            let subscription = viewModel.isLoading.subscribeOn(scheduler).bind(to: results)
            
            scheduler.scheduleAt(3000) { subscription.dispose() }
            scheduler.start()
            
            XCTAssertEqual(results.events[0].time, 100)
            XCTAssertTrue(results.events[0].value.element!)
            
            XCTAssertEqual(results.events[1].time, 201)
            XCTAssertFalse(results.events[1].value.element!)
        }
    }
    
    /**
     Turns 
     Input:
     |--true-----false----------->
     |----true-------false----------->
     |-------------true------false----------->
     |------------true-----false----------->
     |------------true--------false----------->
     |--------------------------------true--false----------->
     
     Into output:
     |--true------------------false---true--false-------->
     */
    func testMultipleObservers() {
        driveOnScheduler(scheduler) {
            //1. arrange
            
            let isLoading1 = scheduler.createHotObservable([
                next(100, true),
                next(200, false)
            ]).asObservable()
            
            let isLoading2 = scheduler.createHotObservable([
                next(110, true),
                next(220, false)
            ]).asObservable()
            
            let isLoading3 = scheduler.createHotObservable([
                next(210, true),
                next(230, false)
            ]).asObservable()
            
            let isLoading4 = scheduler.createHotObservable([
                next(205, true),
                next(225, false)
            ]).asObservable()
            
            let isLoading5 = scheduler.createHotObservable([
                next(205, true),
                next(240, false)
            ]).asObservable()
            
            let isLoading21 = scheduler.createHotObservable([
                next(280, true),
                next(290, false)
            ]).asObservable()
            
            let viewModel = LoadingViewModel([
                isLoading1, isLoading2, isLoading3, isLoading4, isLoading5,
                isLoading21
            ], mainScheduler: scheduler)
            
            //2. execute
            let results = scheduler.createObserver(Bool.self)
            let subscription = viewModel.isLoading.subscribeOn(scheduler).bind(to: results)
            
            scheduler.scheduleAt(3000) { subscription.dispose() }
            scheduler.start()
            
            XCTAssertEqual(results.events[0].time, 100)
            XCTAssertTrue(results.events[0].value.element!)
            
            XCTAssertEqual(results.events[1].time, 241)
            XCTAssertFalse(results.events[1].value.element!)
            
            XCTAssertEqual(results.events[2].time, 280)
            XCTAssertTrue(results.events[2].value.element!)
            
            XCTAssertEqual(results.events[3].time, 291)
            XCTAssertFalse(results.events[3].value.element!)
        }
    }
    
    /**
     Turns
     Input:
     |--true-----false----------->
     |-----------true----------false->
     
     into output
     |--true-------------------false---->
     */
    func testOverLap() {
        driveOnScheduler(scheduler) {
            //1. arrange
            
            let isLoading1 = scheduler.createHotObservable([
                next(100, true),
                next(200, false)
                ]).asObservable()
            
            let isLoading2 = scheduler.createHotObservable([
                next(200, true),
                next(300, false)
                ]).asObservable()
            
            let viewModel = LoadingViewModel([isLoading1, isLoading2], mainScheduler: scheduler)
            
            //2. execute
            let results = scheduler.createObserver(Bool.self)
            let subscription = viewModel.isLoading.subscribeOn(scheduler).bind(to: results)
            
            scheduler.scheduleAt(3000) { subscription.dispose() }
            scheduler.start()
            
            //3. assert
            XCTAssertEqual(results.events[0].time, 100)
            XCTAssertTrue(results.events[0].value.element!)
            
            XCTAssertEqual(results.events[1].time, 301)
            XCTAssertFalse(results.events[1].value.element!)
            
            XCTAssertEqual(results.events.count, 2)
        }
    }
    
    /**
     Turns
     Input `Observable`:
     |------------------T----------->
     
     Loading:
     |---------true----------false-->
     
     into output `Observable`:
     |-------------------------T---->
     
     (Type `String` is for testing purposes)
     */
    func testWaitFor_whileLoading() {
        driveOnScheduler(scheduler) {
            //1. arrange
            
            let input = scheduler.createHotObservable([next(1000, "Input")])
            
            let isLoading = scheduler.createHotObservable([
                next(500, true),
                next(2000, false)
                ]).asObservable()
            
            let viewModel = LoadingViewModel([isLoading], mainScheduler: scheduler)
            
            //2. execute
            let results = scheduler.createObserver(String.self)
            let subscription = input.waitFor(viewModel.isLoading).bind(to: results)
            
            scheduler.scheduleAt(3000) { subscription.dispose() }
            scheduler.start()
            
            //3. assert
            XCTAssertEqual(results.events[0].time, 2002)
            XCTAssertEqual(results.events[0].value.element!, "Input")
        }
    }
    
    /**
     Turns
     Input `Observable`:
     |-------------------------T---->
     
     Loading:
     |--true----------false--------->
     
     into output `Observable`
     |-------------------------T---->
     
     (Type `String` is for testing purposes)
     */
    func testWaitFor_afterLoading() {
        driveOnScheduler(scheduler) {
            //1. arrange
            
            let input = scheduler.createHotObservable([next(1500, "Input")])
            
            let isLoading = scheduler.createHotObservable([
                next(500, true),
                next(900, false)
                ]).asObservable()
            
            let viewModel = LoadingViewModel([isLoading], mainScheduler: scheduler)
            
            //2. execute
            let results = scheduler.createObserver(String.self)
            let subscription = input.waitFor(viewModel.isLoading).bind(to: results)
            
            scheduler.scheduleAt(3000) { subscription.dispose() }
            scheduler.start()
            
            //3. assert
            XCTAssertEqual(results.events[0].time, 1500)
            XCTAssertEqual(results.events[0].value.element!, "Input")
        }
    }
    
    /**
     Turns
     Input `Observable`:
     |--------------------T--------->
     
     Loading:
     |------------------------------>
     
     into output `Observable`
     |--------------------T--------->
     
     (Type `String` is for testing purposes)
     */
    func testWaitFor_ghostLoading() {
        driveOnScheduler(scheduler) {
            //1. arrange
            
            let input = scheduler.createHotObservable([next(1500, "Input")])
            
            let viewModel = LoadingViewModel([], mainScheduler: scheduler)
            
            //2. execute
            let results = scheduler.createObserver(String.self)
            let subscription = input.waitFor(viewModel.isLoading).bind(to: results)
            
            scheduler.scheduleAt(3000) { subscription.dispose() }
            scheduler.start()
            
            //3. assert
            XCTAssertEqual(results.events[0].time, 1500)
            XCTAssertEqual(results.events[0].value.element!, "Input")
        }
    }
    
    /**
     Turns
     Input `SharedSequence`:
     |------------------T----------->
     
     Loading:
     |---------true----------false-->
     
     into output `SharedSequence`:
     |-------------------------T---->
     
     (Type `String` is for testing purposes)
     */
    func testDriverWaitFor_whileLoading() {
        driveOnScheduler(scheduler) {
            //1. arrange
            
            let input = scheduler.createHotObservable([next(1000, "Input")])
                .asDriver(onErrorDriveWith: .never())
            
            let isLoading = scheduler.createHotObservable([
                next(500, true),
                next(2000, false)
                ]).asObservable()
            
            let viewModel = LoadingViewModel([isLoading], mainScheduler: scheduler)
            
            //2. execute
            let results = scheduler.createObserver(String.self)
            let subscription = input.waitFor(viewModel.isLoading).drive(results)
            
            scheduler.scheduleAt(3000) { subscription.dispose() }
            scheduler.start()
            
            //3. assert
            XCTAssertEqual(results.events[0].time, 2003)
            XCTAssertEqual(results.events[0].value.element!, "Input")
        }
    }
    
    /**
     Turns
     Input `SharedSequence`:
     |-------------------------T---->
     
     Loading:
     |--true----------false--------->
     
     into output `SharedSequence`:
     |-------------------------T---->
     
     (Type `String` is for testing purposes)
     */
    func testDriverWaitFor_afterLoading() {
        driveOnScheduler(scheduler) {
            //1. arrange
            
            let input = scheduler.createHotObservable([next(1500, "Input")])
                .asDriver(onErrorDriveWith: .never())
            
            let isLoading = scheduler.createHotObservable([
                next(500, true),
                next(900, false)
                ]).asObservable()
            
            let viewModel = LoadingViewModel([isLoading], mainScheduler: scheduler)
            
            //2. execute
            let results = scheduler.createObserver(String.self)
            let subscription = input.waitFor(viewModel.isLoading).drive(results)
            
            scheduler.scheduleAt(3000) { subscription.dispose() }
            scheduler.start()
            
            //3. assert
            XCTAssertEqual(results.events[0].time, 1502)
            XCTAssertEqual(results.events[0].value.element!, "Input")
        }
    }
    
    /**
     Turns
     Input `SharedSequence`:
     |--------------------T--------->
     
     Loading:
     |------------------------------>
     
     into output `SharedSequence`:
     |--------------------T--------->
     
     (Type `String` is for testing purposes)
     */
    func testDriverWaitFor_ghostLoading() {
        driveOnScheduler(scheduler) {
            //1. arrange
            
            let input = scheduler.createHotObservable([next(1500, "Input")])
                .asDriver(onErrorDriveWith: .never())
            
            let viewModel = LoadingViewModel([], mainScheduler: scheduler)
            
            //2. execute
            let results = scheduler.createObserver(String.self)
            let subscription = input.waitFor(viewModel.isLoading).drive(results)
            
            scheduler.scheduleAt(3000) { subscription.dispose() }
            scheduler.start()
            
            //3. assert
            XCTAssertEqual(results.events[0].time, 1502)
            XCTAssertEqual(results.events[0].value.element!, "Input")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
