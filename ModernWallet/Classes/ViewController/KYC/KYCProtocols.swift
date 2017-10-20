//
//  KYCProtocols.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 9/25/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import SwiftSpinner
import Foundation
import WalletCore
import RxSwift

protocol KYCPhotoPlaceholder {
    weak var photoPlaceholder: KYCPhotoPlaceholderView!{get set}
}

protocol KYCDocumentTypeAware {
    var kYCDocumentType: KYCDocumentType{get}
}

protocol KYCStepBinder: class {
    var documentsViewModel: KYCDocumentsViewModel! {get set}
    var documentsUploadViewModel: KycUploadDocumentsViewModel! {get set}
    
    var loadingViewModel: LoadingViewModel {get}
    func bindKYC(disposedBy disposeBag: DisposeBag)
}

extension KYCStepBinder where Self: UIViewController, Self: KYCDocumentTypeAware & KYCPhotoPlaceholder {
    func loadingViewModelFactory() -> LoadingViewModel {
        return LoadingViewModel([
            self.documentsUploadViewModel.loadingViewModel.isLoading,
            self.documentsViewModel.loadingViewModel.isLoading
        ])
    }
    
    func bindKYC(disposedBy disposeBag: DisposeBag) {
        documentsViewModel.documents
            .subscribeToFillImage(forVC: self)
            .disposed(by: disposeBag)
        
        loadingViewModel.isLoading
            .skipWhileWithIndex{isLoading, index in index == 0 && isLoading == false}
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
    }
}

