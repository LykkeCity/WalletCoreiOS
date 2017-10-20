//
//  LWRxKYCManager.swift
//  WalletCore
//
//  Created by Georgi Stanev on 9/25/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class LWRxKYCManager: LWKYCDocumentsModel {
    
    public typealias Result = ApiResult<[AnyHashable: Any]>
    
    private let imageResult = Variable<Result?>(nil)
    
    public static var instance: LWRxKYCManager = {
        return LWRxKYCManager()
    }()
    
    public func saveWithResult(image: UIImage, for type: KYCDocumentType) -> Observable<Result> {
        imageResult.value = .loading
        super.save(image, for: type)
        return imageResult.asObservable().filterNil()
    }
    
    public override func sendImageManager(_ manager: LWSendImageManager!, didSucceedWithData data: [AnyHashable : Any]!) {
        imageResult.value = .success(withData: data)
        super.sendImageManagerSentImage(manager)
    }
    
    public override func sendImageManager(_ manager: LWSendImageManager!, didFailWithErrorMessage message: String!) {
        imageResult.value = .error(withData: ["Message": message])
        super.sendImageManager(manager, didFailWithErrorMessage: message)
    }
}


public extension ObservableType where Self.E == ApiResult<LWRxKYCManager.Result> {
    public func filterSuccess() -> Observable<LWRxKYCManager.Result> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func filterError() -> Observable<[AnyHashable : Any]>{
        return map{$0.getError()}.filterNil()
    }
    
    public func filterNotAuthorized() -> Observable<Bool> {
        return filter{$0.notAuthorized}.map{_ in true}
    }
    
    public func filterForbidden() -> Observable<Void> {
        return filter{$0.isForbidden}.map{_ in Void()}
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}
