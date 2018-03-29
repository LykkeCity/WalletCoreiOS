//
//  MarketCapCellViewModel.swift
//  WalletCore
//
//  Created by Vasil Garov on 21.03.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class MarketCapViewModel {
    
    public let symbol: Driver<String>
    public let price: Driver<String>
    public let marketCap: Driver<String>
    public let percentChange: Driver<String>
    public let imgUrl: Driver<URL?>
    
    public let marketCapResult: LWModelMarketCapResult
    
    public init(_ marketCapResult: LWModelMarketCapResult) {
        
        self.marketCapResult = marketCapResult

        self.symbol = Driver.just(marketCapResult.symbol)
        
        self.price = Driver
            .just(marketCapResult.price)
            .map{ $0.convertAsCurrency(code: "USD", symbol: "$", accuracy: 2) }
        
        self.marketCap = Driver
            .just(marketCapResult.marketCap)
            .map{ $0.convertAsCurrency(code: "USD", symbol: "$", accuracy: 2) }
        
        self.percentChange = Driver
            .just(marketCapResult.percentChange)
            .map{ "\($0)%" }
        
        self.imgUrl = Driver.never()
    }
}
