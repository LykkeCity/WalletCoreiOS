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
        super.save(image, for: type)
        
        //Nulify imageResult so that the consumers gets loading event immediately and the last uploaded image
        imageResult.value = nil
        return imageResult.asObservable()
            .filterNil()
            .take(1) // take just one result (if this line is ommited there is a chance to emit more than one result, which brakes loading view models)
            .startWith(.loading)
    }
    
    public override func sendImageManagerSentImage(_ manager: LWSendImageManager!) {
        imageResult.value = .success(withData: [:])
        super.sendImageManagerSentImage(manager)
    }
    
    public override func sendImageManager(_ manager: LWSendImageManager!, didSucceedWithData data: [AnyHashable : Any]!) {
        imageResult.value = .success(withData: data)
        super.sendImageManager(manager, didSucceedWithData: data)
    }
    
    public override func sendImageManager(_ manager: LWSendImageManager!, didFailWithErrorMessage message: String!) {
        imageResult.value = .error(withData: ["Message": message])
        super.sendImageManager(manager, didFailWithErrorMessage: message)
    }
}
