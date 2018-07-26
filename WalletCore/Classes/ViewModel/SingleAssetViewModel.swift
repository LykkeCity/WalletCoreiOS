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

public protocol SingleAssetFormatterProtocol {
    func formatTitle(forAsset asset: LWAssetModel) -> String
}

public class SingleAssetFormatter: SingleAssetFormatterProtocol {
    public func formatTitle(forAsset asset: LWAssetModel) -> String {
        return asset.displayId ?? ""
    }
}

open class SingleAssetViewModel {

    /// Current asset's ID
    public let asset: Variable<LWAssetModel>

    /// Row's title
    public var title: Driver<String>

    /// Assets icon (if present)
    public let iconUrl: Driver<URL?>

    /// Determine wether the asset is a selection from a list
    public let isSelected = Variable<Bool>(false)

    private let disposeBag = DisposeBag()

    init(withAsset asset: Variable<LWAssetModel>, formatter: SingleAssetFormatterProtocol) {

        self.asset = asset

        self.title = asset.asObservable()
            .map { formatter.formatTitle(forAsset: $0) }
            .asDriver(onErrorJustReturn: "")

        self.iconUrl = asset.asObservable()
            .map { $0.iconUrl }
            .asDriver(onErrorJustReturn: nil)
    }
}
