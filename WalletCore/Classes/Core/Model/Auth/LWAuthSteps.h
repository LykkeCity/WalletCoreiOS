//
//  LWAuthSteps.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 27.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWDocumentsStatus.h"


typedef NS_ENUM(NSInteger, LWAuthStep) {
    LWAuthStepValidation,
    LWAuthStepEntryPoint,
    LWAuthStepAuthentication,
    LWAuthStepValidatePIN,
    LWAuthStepCheckDocuments,
    
    LWAuthStepSMSCode,
    LWAuthStepRegisterPassword,
//    LWAuthStepRegisterConfirmPassword,
    LWAuthStepRegisterHint,
    LWAuthStepRegisterFullName,
    LWAuthStepRegisterPhone,
    LWAuthStepRegisterPhoneConfirm,
    LWAuthStepRegisterSelfie,
    LWAuthStepRegisterIdentity,
    LWAuthStepRegisterUtilityBill,
    LWAuthStepRegisterKYCSubmit,
    LWAuthStepRegisterKYCPending,
    LWAuthStepRegisterKYCInvalidDocuments,
    LWAuthStepRegisterKYCRestricted,
    LWAuthStepRegisterKYCSuccess,
    LWAuthStepRegisterPINSetup
};


@interface LWAuthSteps : NSObject {
    
}

+ (LWAuthStep)getNextDocumentByStatus:(LWDocumentsStatus *)status;
+ (KYCDocumentType)getDocumentTypeByStep:(LWAuthStep)step;
+ (NSString *)titleByStep:(LWAuthStep)step;

@end
