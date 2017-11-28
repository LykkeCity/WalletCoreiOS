//
//  TwitterTimeLineJsonPacket.swift
//  LykkeBlueLife
//
//  Created by Georgi Stanev on 28.11.17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import UIKit

public class TwitterTimeLineJsonPacket: LWAuthorizePacket {
    
    public struct Body {
        public let accountEmail: String
        public let searchQuery: String
        public var isExtendedSearch: Bool? = nil
        public var maxResult: Int? = nil
        public var untilDate: String? = nil
        public var pageSize: Int? = nil
        public var pageNumber: Int? = nil
        
        public init(accountEmail: String, searchQuery: String) {
            self.accountEmail = accountEmail
            self.searchQuery = searchQuery
        }
    }
    
    public var body: Body
    
    public var model: [[AnyHashable: Any]]
    
    public init(body: Body, observer: Any) {
        self.body = body
        model = [[:]]
        super.init()
        self.observer = observer
    }
    
    required public init!(json: Any!) {
        fatalError("init(json:) has not been implemented")
    }
    
    override public func parseResponse(_ response: Any!, error: Error!) {
        guard !isRejected else{ return }
        
        if let result = response as? [[AnyHashable: Any]]  {
            model = result
        }
    }
    
    //TODO: check according TEST flag
    override public var urlBase: String {
        return "https://blue-api-dev.lykkex.net/api"
    }
    
    override public var urlRelative: String! {
        return "twitter/getTweetsJSON"
    }
    
    override public var type: GDXRESTPacketType {
        return .POST
    }
    
    override public var params: [AnyHashable : Any] {
        return body.asDictionary()
    }
}

extension TwitterTimeLineJsonPacket.Body {
    func asDictionary() -> [AnyHashable: Any] {
        var dict: [AnyHashable: Any] = [
            "AccountEmail": accountEmail,
            "SearchQuery": searchQuery
        ]
        
        if let isExtendedSearch = isExtendedSearch {
            dict["IsExtendedSearch"] = isExtendedSearch
        }
        
        if let maxResult = maxResult {
            dict["MaxResult"] = maxResult
        }
        
        if let untilDate = untilDate {
            dict["UntilDate"] = untilDate
        }
        
        if let pageSize = pageSize {
            dict["PageSize"] = pageSize
        }
        
        if let pageNumber = pageNumber {
            dict["PageNumber"] = pageNumber
        }
        
        return dict
    }
}

