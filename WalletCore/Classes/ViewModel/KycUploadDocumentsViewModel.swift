//
//  KycUploadDocumentsViewModel.swift
//  WalletCore
//
//  Created by Georgi Stanev on 9/26/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class KycUploadDocumentsViewModel {
    
    /// A driver with the taken image, it receives events when the api returns successful response
    public let image: Driver<UIImage?>
    
    /// A driver with errors dictionary
    public let error: Driver<[AnyHashable : Any]>
    
    /// A driver with success data
    public let success: Driver<[AnyHashable : Any]>
    
    /// Loading indicator
    public let loadingViewModel: LoadingViewModel
    
    
    ///
    /// - Parameters:
    ///   - image: Taken image
    ///   - type: Variable with kyc document type
    ///   - kycManager: KYCManager
    public init(
        forImage image: Observable<UIImage?>,
        withType type: Variable<KYCDocumentType?>,
        kycManager: LWRxKYCManager = LWRxKYCManager.instance
    ) {
        let uploadImageObservable = image
            .filterNil()
            .flatMapLatest { image -> Observable<(result: LWRxKYCManager.Result, image: UIImage)> in
                guard let type = type.value else{return Observable.never()}
                return kycManager
                    .saveWithResult(image: image, for: type)
                    .map{(
                        result: $0,
                        image: image
                    )}
            }
            .shareReplay(1)
        
        self.error = uploadImageObservable
            .map{$0.result}
            .filterError()
            .asDriver(onErrorJustReturn: [:])
        
        self.success = uploadImageObservable
            .map{$0.result}
            .filterSuccess()
            .asDriver(onErrorJustReturn: [:])
        
        self.image = uploadImageObservable
            .map{$0.result.isSuccess ? $0.image : nil}
            .asDriver(onErrorJustReturn: nil)
        
        self.loadingViewModel = LoadingViewModel([
            uploadImageObservable.map{$0.result}.isLoading()
        ])
    }
}
