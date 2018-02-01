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
    
    public override func sendImageManagerSentImage(_ manager: LWSendImageManager) {
        imageResult.value = .success(withData: [:])
        super.sendImageManagerSentImage(manager)
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
