//
//  SingleAssetViewModel.swift
//  WalletCore
//
//  Created by Lyubomir Marinov on 26.01.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public protocol SingleAssetFormatterProtocol{}

public class SingleAssetFormatter: SingleAssetFormatterProtocol{}

open class SingleAssetViewModel {
    
    /// Current asset's ID
    public let identity: Driver<String>
    
    /// Asset's name
    public var name: Driver<String>
    
    /// Asset's full name
    public var fullName: Driver<String>
    
    /// Asset's short name
    public var shortName: Driver<String>
    
    /// Assets icon (if present)
    public let iconUrl: Driver<URL?>
    
    /// Determine wether the asset is a selection from a list
    public let isSelected = Variable<Bool>(false)
    
    init(withAsset asset: Observable<LWAssetModel>, formatter: SingleAssetFormatterProtocol) {
        
        self.identity = asset
            .map{$0.identity}
            .asDriver(onErrorJustReturn: "")
        
        self.name = asset
            .map{$0.displayName}
            .asDriver(onErrorJustReturn: "")
        
        self.fullName = asset
            .map{$0.displayFullName}
            .asDriver(onErrorJustReturn: "")
        
        self.shortName = asset
            .map{$0.displayId}
            .asDriver(onErrorJustReturn: "")
        
        self.iconUrl = asset
            .map{$0.iconUrl}
            .asDriver(onErrorJustReturn: nil)
        
    }
}
