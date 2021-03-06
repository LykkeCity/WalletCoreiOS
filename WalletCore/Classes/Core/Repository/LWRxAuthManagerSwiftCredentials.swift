//
//  LWRxAuthManagerSwiftCredentials.swift
//  LykkeWallet
//
//  Created by Bozidar Nikolic on 7/26/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift

public class LWRxAuthManagerSwiftCredentials: NSObject{
    
    public typealias Packet = LWPacketSwiftCredential
    public typealias Result = ApiResult<LWSwiftCredentialsModel>
    public typealias ResultType = LWSwiftCredentialsModel
    public typealias RequestParams = (String)
    
    override init() {
        super.init()
        subscribe(observer: self, succcess: #selector(self.successSelector(_:)), error: #selector(self.errorSelector(_:)))
    }
    
    deinit {
        unsubscribe(observer: self)
    }
    
    @objc func successSelector(_ notification: NSNotification) {
        onSuccess(notification)
    }
    
    @objc func errorSelector(_ notification: NSNotification) {
        onError(notification)
    }
}

extension LWRxAuthManagerSwiftCredentials: AuthManagerProtocol{
    public func createPacket(withObserver observer: Any, params: (String)) -> LWPacketSwiftCredential {
        return Packet(observer: observer, assetId: params)
    }
    
    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        
        guard let model = LWCache.instance().swiftCredentialsDict?.first(where: {credential -> Bool in (credential.key as? String ?? "") == packet.identity})?.value
            as? LWSwiftCredentialsModel else {
                return Result.error(withData: ["Message": "Credentials not found."])
        }
        
        return Result.success(withData: model)
    }
}

extension LWPacketSwiftCredential {
    convenience init(observer: Any, assetId: String) {
        self.init()
        self.observer = observer
        self.identity = assetId
    }
}


