//
//  ValidateWordsViewModel.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 12.08.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class ValidateWordsViewModel {
    
    // IN:
    /// Users email
    public let email = Variable<String>("")
    
    /// Valid seed words
    public let seedWords = Variable<String>("")
    
    // OUT:
    /// Validity of the seed words
    public let areSeedWordsValid: Observable<Bool>
    
    /// Ownership data from the API
    public let isOwnershipConfirmed: Observable<Bool>
    
    /// Triggered when SUBMIT button is tapped
    public let trigger = PublishSubject<Void>()
    
    /// Loading view model
    public let loadingViewModel: LoadingViewModel
    
    /// Errors occured
    public let errors: Observable<[AnyHashable: Any]>
    
    public let error: Driver<[AnyHashable: Any]>
    
    private let disposeBag = DisposeBag()
    
    public init(authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        areSeedWordsValid = seedWords.asObservable()
            .mapToSeparateWords()
            .mapToCorrectSeedWords()
        
        let ownershipMessageRequest = trigger
            .withLatestFrom(email.asObservable())
            .filter { $0.isNotEmpty }
            .flatMapLatest { authManager.ownershipMessage.request(withParams: (email: $0, signature: "")) }
            .shareReplay(1)
        
        let ownershipMessageWithSignatureRequest = ownershipMessageRequest.filterSuccess()
            .map { LWPrivateKeyManager.shared().signatureForMessage(withLykkeKey: $0.ownershipMessage) }
            .withLatestFrom(email.asObservable()) { (email: $1, signature: $0) }
            .flatMapLatest { authManager.ownershipMessage.request(withParams: $0) }
            .shareReplay(1)
        
        self.isOwnershipConfirmed = ownershipMessageWithSignatureRequest.filterSuccess()
            .map { $0.confirmedOwnership }

        self.error = Observable.merge([
            ownershipMessageRequest.filterError(),
            ownershipMessageWithSignatureRequest.filterError()
            ])
            .asDriver(onErrorJustReturn: [:])
        
        self.loadingViewModel = LoadingViewModel([    
            ownershipMessageRequest.isLoading(),
            ownershipMessageWithSignatureRequest.isLoading()
        ])
        
        self.errors = Observable.merge([
            ownershipMessageRequest.filterError(),
            ownershipMessageWithSignatureRequest.filterError()
        ])
        
    }
}

extension Observable where E == String {
    
    func mapToSeparateWords() -> Observable<[String]> {
        return map {
            return $0.components(separatedBy: " ")
        }
    }
    
}

extension Observable where E == [String] {
    
    func mapToCorrectSeedWords() -> Observable<Bool> {
        return map { data in
            if data.count == 12 || data.count == 24 {
                guard let _ = LWPrivateKeyManager.keyData(fromSeedWords: data) else {
                    return false
                }
                
                //set the private key from seed words !
                LWPrivateKeyManager.shared().savePrivateKeyLykke(fromSeedWords: data)
                
                return true
            }
            
            return false
        }
    }
    
}
