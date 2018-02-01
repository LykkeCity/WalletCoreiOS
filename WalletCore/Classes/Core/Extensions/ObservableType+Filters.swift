//
//  ObservableTypeFilters.swift
//  WalletCore
//
//  Created by Teodor Penkov on 1.02.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift

// MARK: -  Default unwrapped implementation
public extension ObservableType {
    
    func filterSuccess<T>() -> Observable<T> where Self.E == ApiResult<T> {
        return map { $0.getSuccess() }
            .filterNil()
    }
    
    public func filterError<T>() -> Observable<[AnyHashable : Any]> where Self.E == ApiResult<T>{
        return map { $0.getError() }
            .filterNil()
    }
    
    public func filterNotAuthorized<T>() -> Observable<Bool> where Self.E == ApiResult<T> {
        return filter { $0.notAuthorized }
            .map { _ in true }
    }
    
    public func isLoading<T>() -> Observable<Bool> where Self.E == ApiResult<T> {
        return map { $0.isLoading }
    }
    
    public func filterForbidden<T>() -> Observable<Void> where Self.E == ApiResult<T> {
        return filter { $0.isForbidden }
            .map{ _ in () }
    }
}

// MARK: - Concrecte implementations
public extension ObservableType where Self.E == ApiResult<LWSpotWallet?> {
    
    public func filterSuccess() -> Observable<LWSpotWallet?> {
        return filter{ $0.isSuccess }
            .map { return $0.getSuccess() ?? nil }
    }
}

public extension ObservableType where Self.E == (apiResult: ApiResult<LWPacketGraphData>, interval: Bool) {
    
    public func filterSuccess() -> Observable<LWPacketGraphData> {
        return map { $0.apiResult.getSuccess() }
            .filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return filter{!$0.interval}.map{$0.apiResult.isLoading}
    }
}
// TODO: do we need this?
//
//public extension ObservableType where Self.E == [ApiResult<LWModelOffchainResult>] {
//    public func filterSuccess() -> Observable<[LWModelOffchainResult]> {
//        return filter{ $0.allSuccessful() }
//            .map{ $0.filterSuccess() }
//    }
//}
//
//extension Array where Element == ApiResult<LWModelOffchainResult> {
//    func allSuccessful() -> Bool {
//        return first{!$0.isSuccess} == nil
//    }
//
//    func filterSuccess() -> [LWModelOffchainResult] {
//        return map{ $0.getSuccess() }
//            .filter{ $0 != nil }
//            .map{ $0! }
//    }
//}

