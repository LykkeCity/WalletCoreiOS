//
//  CommunityUsersCountPacket.swift
//  WalletCore
//
//  Created by Nacho Nachev on 4.12.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit

public class CommunityUsersCountPacket: LWPacket {

    public var count: Int?
    
    public init(observer: Any) {
        super.init()
        self.observer = observer
    }
    
    required public init!(json: Any!) {
        fatalError("init(json:) has not been implemented")
    }
    
    override public func parseResponse(_ response: Any!, error: Error!) {
        guard !isRejected, let response = response as? [AnyHashable: Any] else { return }
        
        count = response["Count"] as? Int
    }
    
    //TODO: check according TEST flag
    override public var urlBase: String {
        return "https://\(LWKeychainManager.instance().blueAddress!)/api"
    }
    
    override public var urlRelative: String! {
        return "client/getUsersCountByPartner"
    }
    
    override public var type: GDXRESTPacketType {
        return .GET
    }

}
