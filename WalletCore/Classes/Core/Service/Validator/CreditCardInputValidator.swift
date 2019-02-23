//
//  CreditCardInputValidator.swift
//  WalletCore
//
//  Created by Vladimir Dimov on 4.07.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import Foundation

public class CreditCardInputValidator {
    func validate(input: LWPacketGetPaymentUrlParams) -> ApiResult<LWPacketGetPaymentUrl>{
        
        guard let amountValue = input.amount.decimalValue, amountValue > 0 else {
            return .error(withData: ["Message": Localize("addMoney.newDesign.emptyAmountField")])
        }
        
        if  input.firstName.isEmpty {
            return .error(withData: ["Message": Localize("addMoney.newDesign.emptyFirstNameField"), "Field": "FirstName"])
        }
        
        if  input.lastName.isEmpty {
            return .error(withData: ["Message": Localize("addMoney.newDesign.emptyLastNameField"), "Field": "LastName"])
        }
        
        if  input.address.isEmpty {
            return .error(withData: ["Message": Localize("addMoney.newDesign.emptyAddressField"), "Field": "Address"])
        }
        
        if  input.city.isEmpty {
            return .error(withData: ["Message": Localize("addMoney.newDesign.emptyCityField"), "Field": "City"])
        }
        
        if  input.zip.isEmpty {
            return .error(withData: ["Message": Localize("addMoney.newDesign.emptyZipField"), "Field": "Zip"])
        }
        
        if input.country.isEmpty {
            return .error(withData: ["Message": Localize("addMoney.newDesign.emptyCountryField"), "Field": "Country"])
        }
        
        if input.phone.isEmpty {
            return .error(withData: ["Message": Localize("addMoney.newDesign.emptyCodeAndPhoneField"), "Field": "Phone"])
        }
                
        return ApiResult.success(withData: LWPacketGetPaymentUrl())
    }

}
