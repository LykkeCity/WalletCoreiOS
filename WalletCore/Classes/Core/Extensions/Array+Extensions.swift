//
//  Array+Extensions.swift
//  WalletCore
//
//  Created by Georgi Stanev on 3.11.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public extension Array where Element == Disposable {
    public func disposed(by disposeBag: DisposeBag) {
        self.forEach { $0.disposed(by: disposeBag) }
    }
}

extension Array {
    var randomElement: Element?  {
        if isEmpty { return nil }
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
}

extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

extension Collection {
    
    subscript (opt index: Index) -> Element? {
        return self.indices.contains(index) ? self[index] : nil
    }
}

public extension Array where Element:LWSpotWallet {
    
    //calculate balance in base according to the base asset
    func calculateBalanceInBase() -> Decimal {
        return self.map { $0.amountInBase.decimalValue }.reduce(0.0, +)
    }
    
    func calculateBalance() -> Decimal {
        return self.map { $0.balance.decimalValue }.reduce(0.0, +)
    }
}
