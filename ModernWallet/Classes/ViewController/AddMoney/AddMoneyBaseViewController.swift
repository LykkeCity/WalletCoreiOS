//
//  AddMoneyBaseViewController.swift
//  ModernMoney
//
//  Created by Georgi Ivanov on 8.02.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import RxSwift

protocol AddMoneyTransfer: class {
    var assetToAdd: LWAssetModel { get set }
}

class AddMoneyBaseViewController: UIViewController {

    var assetModel = Variable<LWAssetModel?>(nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(assetModel.value != nil, "Transfer asset must be set before displayng view controller \(self)")
    }
    
    func аssetObservable() -> Observable<LWAssetModel> {
        return assetModel.asObservable().map { (val) -> LWAssetModel in
            return val ?? LWAssetModel()
        }
    }
}

extension AddMoneyBaseViewController: AddMoneyTransfer {
    var assetToAdd: LWAssetModel {
        get {
            return self.assetModel.value ?? LWAssetModel()
        }
        
        set {
            self.assetModel.value = newValue
        }
    }
}
