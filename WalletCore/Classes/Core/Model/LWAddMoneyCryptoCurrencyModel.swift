//
//  LWAddMoneyCryptoCurrencyModel.swift
//  WalletCore
//
//  Created by Ivan Stefanovic on 12/20/17.
//

import UIKit

public class LWAddMoneyCryptoCurrencyModel {
    public let name: String
    public let address: String?
    public var imgUrl: URL?
    
    public init(name: String, address: String?) {
        self.name = name
        self.address = address
        self.imgUrl = nil
    }
    public init(name: String, address: String?, imageUrl: URL?) {
        self.name = name
        self.address = address
        self.imgUrl = imageUrl
    }
    
}
