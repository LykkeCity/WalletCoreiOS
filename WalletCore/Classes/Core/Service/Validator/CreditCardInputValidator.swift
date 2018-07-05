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
            return .error(withData: ["Amount": "Please fill in the Amount field."])
        }
        
        if  input.firstName.isEmpty {
            return .error(withData: ["FirstName": "Please fill in the FirstName field."])
        }
        
        if  input.lastName.isEmpty {
            return .error(withData: ["LastName": "Please fill in the LastName field."])
        }
        
        if  input.address.isEmpty {
            return .error(withData: ["Address": "Please fill in the Address field."])
        }
        
        if  input.city.isEmpty {
            return .error(withData: ["City": "Please fill in the City field."])
        }
        
        if  input.zip.isEmpty {
            return .error(withData: ["Zip": "Please fill in the Zip field."])
        }
        
        if  input.zip.isEmpty {
            return .error(withData: ["Zip": "Please fill in the Zip field."])
        }
        
        if input.country.isEmpty {
            return .error(withData: ["Country": "Please fill in the Country field."])
        }
        
        
        return ApiResult.success(withData: LWPacketGetPaymentUrl())
    }

}
