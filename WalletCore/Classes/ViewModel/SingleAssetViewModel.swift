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
    public let identity = Variable<String>("")
    
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
    
    private let disposeBag = DisposeBag()
    
    init(withAsset asset: Variable<LWAssetModel>, formatter: SingleAssetFormatterProtocol) {

        self.identity.value = asset.value.identity
        
        self.name = asset.transformToObservable()
            .map{$0.displayName}
            .asDriver(onErrorJustReturn: "")
        
        self.fullName = asset.transformToObservable()
            .map{$0.displayFullName}
            .asDriver(onErrorJustReturn: "")
        
        self.shortName = asset.transformToObservable()
            .map{$0.displayId}
            .asDriver(onErrorJustReturn: "")
        
        self.iconUrl = asset.transformToObservable()
            .map{$0.iconUrl}
            .asDriver(onErrorJustReturn: nil)
        
    }
}

extension Variable where Element == LWAssetModel {
    
    func transformToObservable() -> Observable<LWAssetModel> {
        return Observable.just(value)
    }
    
}
