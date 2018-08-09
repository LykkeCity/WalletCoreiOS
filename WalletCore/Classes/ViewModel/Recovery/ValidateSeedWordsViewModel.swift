//
//  ValidateSeedWordsViewModel.swift
//  WalletCore
//
//  Created by Vladimir Dimov on 24.07.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class ValidateSeedWordsViewModel {
    
    public typealias SignatureData = (signature: String, isConfirmed: Bool)
    
    /// Seed words
    public let typedText = Variable("")

    /// Verify that the words are entered correctly (this enables the SUBMIT button)
    public let areSeedWordsCorrect: Observable<Bool>
    
    /// Ownership data from the API to be used both in the view controller and in the parent view model
    public let ownershipData: Observable<SignatureData>
    
    /// Triggered when SUBMIT button is tapped
    public let checkTrigger = PublishSubject<Void>()
    
    /// Loading
    public let loadingViewModel: LoadingViewModel

    private let disposeBag = DisposeBag()
    
    public init(withEmail email: Observable<String>, authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        areSeedWordsCorrect = typedText.asObservable()
            .mapToSeparateWords()
            .mapToAreAllWordsEnteredCorrectly()

        // Process ownership message
        // Step 1: get the `ownershipMessage` from the API
        // Step 2: generate signature
        // Step 3: return `confirmedOwnership` from the API
        let ownershipRequest = checkTrigger
            .withLatestFrom(email)
            .filter { $0.isNotEmpty }
            .flatMapLatest { email in
                return authManager.ownershipMessage.request(withParams: (email: email, signature: ""))
                    .filterSuccess()
                    .map { LWPrivateKeyManager.shared().signatureForMessage(withLykkeKey: $0.ownershipMessage) }
                    .flatMapLatest { authManager.ownershipMessage.request(withParams: (email: email, signature: $0)) }
            }
            .shareReplay(1)
        
        ownershipData = ownershipRequest.filterSuccess()
            .map { (signature: $0.signature, isConfirmed: $0.confirmedOwnership) }
        
        self.loadingViewModel = LoadingViewModel([
            ownershipRequest.isLoading()
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
    
    func mapToAreAllWordsEnteredCorrectly() -> Observable<Bool> {
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
