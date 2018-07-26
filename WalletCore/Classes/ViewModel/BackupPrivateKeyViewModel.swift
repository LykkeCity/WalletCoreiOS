//
//  BackupPrivateKeyViewModel.swift
//  WalletCore
//
//  Created by Nacho Nachev on 22.11.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift

public class BackupPrivateKeyViewModel {

    public typealias Params = (words: [String], font: UIFont?, typingColor: UIColor, correctColor: UIColor, wrongColor: UIColor)

    typealias TextTypingPair = (text: String?, isTyping: Bool)

    public let words: [String]

    public let typedText = Variable(TextTypingPair("", false))

    public let colorizedText: Observable<NSAttributedString>

    public let areAllWordsCorrect: Observable<Bool>

    public let confirmTrigger = PublishSubject<Void>()

    public let errors: Observable<[AnyHashable: Any]>

    public let success: Observable<Void>

    public let loadingViewModel: LoadingViewModel

    private let authManager: LWRxAuthManager

    private let disposeBag = DisposeBag()

    public init(params: Params, authManager: LWRxAuthManager) {
        words = params.words
        self.authManager = authManager
        let textFont = params.font ?? UIFont.systemFont(ofSize: 20.0)

        let separatedWordsObservable = typedText.asObservable()
            .mapToCheckedWordsAndIsTyping(words: words)

        colorizedText = separatedWordsObservable
            .mapToAttributedString(font: textFont, typingColor: params.typingColor, correctColor: params.correctColor, wrongColor: params.wrongColor)

        areAllWordsCorrect = separatedWordsObservable
            .mapToAreAllWordsEnteredCorrectly(wordsCount: words.count)

        let privateKeyManager = confirmTrigger.asObserver()
            .withLatestFrom(areAllWordsCorrect)
            .filter { $0 }
            .mapToPrivateKeyManager()
            .filterNil()

        let shouldMigrate = privateKeyManager
            .map { [words] (privateKeyManager) -> Bool in
                guard let privateKeyWords = privateKeyManager.privateKeyWords() as? [String] else { return true }
                return privateKeyWords != words
            }
            .shareReplay(1)

        let paramsWithOldEncodedKey = shouldMigrate.filter { $0 }
            .withLatestFrom(privateKeyManager)
            .mapToMigrateParamsWithOldEncodedKey(words: words)
            .shareReplay(1)

        let oldEncodedKey = paramsWithOldEncodedKey
            .map { (_, oldEncodedKey) in return oldEncodedKey }

        let migrationRequest = paramsWithOldEncodedKey
            .flatMap { (params, _) in
                return authManager.walletMigration.request(withParams: params)
            }
            .shareReplay(1)

        let migrationErrors = migrationRequest
            .filterError()

        migrationErrors
            .withLatestFrom(oldEncodedKey)
            .subscribe(onNext: { (oldEncodedPrivateKey) in
                LWPrivateKeyManager.shared().decryptLykkePrivateKeyAndSave(oldEncodedPrivateKey)
            })
            .disposed(by: disposeBag)

        let completeBackupTrigger = Observable.merge([
            shouldMigrate.filter { !$0 }.map { _ in return () },
            migrationRequest.filterSuccess().map { _ in return () }
        ])

        let completeBackupRequest = completeBackupTrigger
            .flatMap { _ in return authManager.walletBackupComplete.request() }

        errors = Observable.merge([ migrationErrors, completeBackupRequest.filterError() ])

        success = completeBackupRequest
            .filterSuccess()
            .map { _ in return Void() }

        loadingViewModel = LoadingViewModel([ migrationRequest.isLoading(), completeBackupRequest.isLoading() ])
    }
}

extension Observable where E == BackupPrivateKeyViewModel.TextTypingPair {

    func mapToCheckedWordsAndIsTyping(words: [String]) -> Observable<([(String, Bool)], Bool)> {
        return map { (data) -> ([(String, Bool)], Bool) in
            guard let text = data.text else {
                return ([], data.isTyping)
            }
            let parsedWords = text.components(separatedBy: " ")
            var isCorrect = true
            let words = parsedWords.enumerated().map { (data) -> (String, Bool) in
                let (index, word) = data
                isCorrect = isCorrect && index < words.count && word == words[index]
                return (word, isCorrect)
            }
            return (words, data.isTyping)
        }
    }

}

extension Observable where E == ([(String, Bool)], Bool) {

    func mapToAttributedString(font: UIFont, typingColor: UIColor, correctColor: UIColor, wrongColor: UIColor) -> Observable<NSAttributedString> {
        return map { (data) -> NSAttributedString in
            var (words, isTyping) = data
            var lastWordWhenTyping: (String, Bool)?
            if isTyping && words.count > 0 {
                lastWordWhenTyping = words.removeLast()
            }
            var attributes: [String: Any] = [NSFontAttributeName: font]
            let attributedText = NSMutableAttributedString()
            var firstWord = true
            for (word, isCorrect) in words {
                let text = firstWord ? word : " \(word)"
                firstWord = false
                attributes[NSForegroundColorAttributeName] = isCorrect ? correctColor : wrongColor
                attributedText.append(NSAttributedString(string: text, attributes: attributes))
            }
            if let (word, _) = lastWordWhenTyping {
                attributes[NSForegroundColorAttributeName] = typingColor
                let text = firstWord ? word : " \(word)"
                attributedText.append(NSAttributedString(string: text, attributes: attributes))
            }
            return attributedText
        }
    }

    func mapToAreAllWordsEnteredCorrectly(wordsCount: Int) -> Observable<Bool> {
        return map { data in
            let (checkedWords, _) = data
            return checkedWords.reduce(checkedWords.count == wordsCount) { (result, checkedWord) in
                let (_, isWordCorrect) = checkedWord
                return result && isWordCorrect
            }
        }
    }

}

extension Observable where E == Bool {

    fileprivate func mapToMigrateParamsWithOldEncodedKey(words: [String]) -> Observable<(LWRxAuthManagerWalletMigration.RequestParams, String)> {
        return mapToPrivateKeyManager()
            .filterNil()
            .mapToMigrateParamsWithOldEncodedKey(words: words)
    }

    fileprivate func mapToPrivateKeyManager() -> Observable<LWPrivateKeyManager?> {
        return map { _ -> LWPrivateKeyManager? in
            guard
                let privateKeyManager = LWPrivateKeyManager.shared(),
                privateKeyManager.wifPrivateKeyLykke != nil,
                privateKeyManager.encryptedKeyLykke != nil
                else {
                    return nil
            }
            return privateKeyManager
        }
    }

}

extension Observable where E == LWPrivateKeyManager {

    fileprivate func mapToMigrateParamsWithOldEncodedKey(words: [String]) -> Observable<(LWRxAuthManagerWalletMigration.RequestParams, String)> {
        return map { (privateKeyManager) -> (LWRxAuthManagerWalletMigration.RequestParams, String) in
            let oldEncodedPrivateKey = privateKeyManager.encryptedKeyLykke!
            let oldPrivateKey = privateKeyManager.wifPrivateKeyLykke!
            privateKeyManager.savePrivateKeyLykke(fromSeedWords: words)
            let model = LWRxAuthManagerWalletMigration.RequestParams(
                fromPrivateKey: oldPrivateKey,
                toPrivateKey: privateKeyManager.wifPrivateKeyLykke!,
                toEncodedPrivateKey: privateKeyManager.encryptedKeyLykke!,
                toPubKey: privateKeyManager.publicKeyLykke!
            )
            return (model, oldEncodedPrivateKey)
        }
    }

}
