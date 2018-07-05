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
            return .error(withData: ["Message": "Please fill in the Amount field."])
        }
        
        if  input.firstName.isEmpty {
            return .error(withData: ["Message": "Please fill in the FirstName field.", "Field": "FirstName"])
        }
        
        if  input.lastName.isEmpty {
            return .error(withData: ["Message": "Please fill in the LastName field.", "Field": "LastName"])
        }
        
        if  input.address.isEmpty {
            return .error(withData: ["Message": "Please fill in the Address field.", "Field": "Address"])
        }
        
        if  input.city.isEmpty {
            return .error(withData: ["Message": "Please fill in the City field.", "Field": "City"])
        }
        
        if  input.zip.isEmpty {
            return .error(withData: ["Message": "Please fill in the Zip field.", "Field": "Zip"])
        }
        
        if input.country.isEmpty {
            return .error(withData: ["Message": "Please fill in the Country field.", "Field": "Country"])
        }
        
        if input.phone.isEmpty {
            return .error(withData: ["Message": "Please fill in the Code and Phone fields.", "Field": "Phone"])
        }
                
        return ApiResult.success(withData: LWPacketGetPaymentUrl())
    }

}
