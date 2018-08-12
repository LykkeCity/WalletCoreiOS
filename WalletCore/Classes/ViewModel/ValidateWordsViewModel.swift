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
    
    public typealias SignatureData = (signature: String, isConfirmed: Bool)
    
    // IN:
    /// Users email
    public let email = Variable<String>("")
    
    /// Valid seed words
    public let seedWords = Variable<String>("")
    
    // OUT:
    /// Validity of the seed words
    public let areSeedWordsValid: Observable<Bool>
    
    /// Ownership data from the API
    public let ownershipData: Observable<SignatureData>
    
    /// Triggered when SUBMIT button is tapped
    public let trigger = PublishSubject<Void>()
    
    /// Loading view model
    public let loadingViewModel: LoadingViewModel
    
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
            .debug("Allegra")
            .do(onNext: { value in
                print("value.signature = \(value.signature)")
                print("value.confirmedOwnership = \(value.confirmedOwnership)")
            })
            .map { LWPrivateKeyManager.shared().signatureForMessage(withLykkeKey: $0.ownershipMessage) }
            .withLatestFrom(email.asObservable()) { (email: $0, signature: $1) }
            .flatMapLatest { authManager.ownershipMessage.request(withParams: $0) }
            .shareReplay(1)
        
        self.ownershipData = ownershipMessageWithSignatureRequest.filterSuccess()
            .map { (signature: $0.signature, isConfirmed: $0.confirmedOwnership) }

        self.error = Observable.merge([
            ownershipMessageRequest.filterError(),
            ownershipMessageWithSignatureRequest.filterError()
            ])
            .asDriver(onErrorJustReturn: [:])
        
        self.loadingViewModel = LoadingViewModel([
            ownershipMessageRequest.isLoading(),
            ownershipMessageWithSignatureRequest.isLoading()
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
                
                return true
            }
            
            return false
        }
    }
    
}
