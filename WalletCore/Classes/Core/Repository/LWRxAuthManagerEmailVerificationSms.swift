//
//  LWRxAuthManagerEmailVerificationSMS.swift
//  Pods
//
//  Created by Lyubomir Marinov on 8/8/18.
//
//

import Foundation
import RxSwift

public class LWRxAuthManagerEmailVerificationSMS: NSObject{
    
    public typealias Packet = LWPacketEmailVerificationGet
    public typealias Result = ApiResult<LWPacketEmailVerificationGet>
    public typealias ResultType = LWPacketEmailVerificationGet
    public typealias RequestParams = (email:String, code:String, accessToken: String)
    
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

extension LWRxAuthManagerEmailVerificationSMS: AuthManagerProtocol{
    public func createPacket(withObserver observer: Any, params: RequestParams) -> LWPacketEmailVerificationGet {
        return Packet(observer: observer, email: params.email, code: params.code, accessToken: params.accessToken)
    }
}

extension LWPacketEmailVerificationGet {
    convenience init(observer: Any, email: String, code: String, accessToken: String) {
        self.init()
        
        self.email = email
        self.code = code
        self.accessToken = accessToken
        self.observer = observer
    }
}

