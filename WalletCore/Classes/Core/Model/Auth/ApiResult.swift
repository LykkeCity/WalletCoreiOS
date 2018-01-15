//
//  ApiResult.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 6/27/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation

public enum ApiResult<Data> {
    case loading
    case success(withData: Data)
    case error(withData: [AnyHashable : Any])
    case notAuthorized
    case forbidden
    
    public var isLoading: Bool {
        guard case .loading = self else {return false}
        return true
    }
    
    public var isSuccess: Bool {
        guard case .success(_) = self else {return false}
        return true
    }
    
    public var isError: Bool {
        guard case .error(_) = self else {return false}
        return true
    }
    
    public var notAuthorized: Bool {
        guard case .notAuthorized = self else {return false}
        return true
    }
    
    public var isForbidden: Bool {
        guard case .forbidden = self else {return false}
        return true
    }
    
    public func getSuccess() -> Data? {
        guard case let .success(data) = self else {return nil}
        return data
    }
    
    public func getError() -> [AnyHashable : Any]? {
        guard case let .error(data) = self else {return nil}
        return data
    }
}

public enum ApiResultList<Data> {
    case loading
    case success(withData: [Data])
    case error(withData: [AnyHashable : Any])
    case notAuthorized
    case forbidden
    
    public var isLoading: Bool {
        guard case .loading = self else {return false}
        return true
    }
    
    public var isSuccess: Bool {
        guard case .success(_) = self else {return false}
        return true
    }
    
    public var isError: Bool {
        guard case .error(_) = self else {return false}
        return true
    }
    
    public var notAuthorized: Bool {
        guard case .notAuthorized = self else {return false}
        return true
    }
    
    public var isForbidden: Bool {
        guard case .forbidden = self else {return false}
        return true
    }
    
    public func getSuccess() -> [Data]? {
        guard case let .success(data) = self else {return nil}
        return data
    }
    
    public func getError() -> [AnyHashable : Any]? {
        guard case let .error(data) = self else {return nil}
        return data
    }
}
