//
//  LWAuthSteps.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 27.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthSteps.h"


@implementation LWAuthSteps {
    
}

+ (LWAuthStep)getNextDocumentByStatus:(LWDocumentsStatus *)status {
    
    LWAuthStep nextStep = LWAuthStepRegisterKYCInvalidDocuments;
    
//    if (!status.isSelfieUploaded) {  //Andrey
//        // to selfie
//        nextStep = LWAuthStepRegisterSelfie;
//    }
//    else if (!status.isIdCardUploaded) {
//        // to identity card
//        nextStep = LWAuthStepRegisterIdentity;
//    }
//    else if (!status.isPOAUploaded) {
//        // to POA
//        nextStep = LWAuthStepRegisterUtilityBill;
//    }
//    else {
//        // to LWAuthStepRegisterKYCSubmit
//        nextStep = LWAuthStepRegisterKYCSubmit;
//    }
//    
//    else {
        nextStep=LWAuthStepRegisterPINSetup;
//    }
    
    return nextStep;
}

+ (KYCDocumentType)getDocumentTypeByStep:(LWAuthStep)step {
    // send photo
    KYCDocumentType type = ((step == LWAuthStepRegisterSelfie)
                            ? KYCDocumentTypeSelfie
                            : ((step == LWAuthStepRegisterIdentity)
                               ? KYCDocumentTypeIdCard
                               : KYCDocumentTypeProofOfAddress));
    return type;
}

+ (NSString *)titleByStep:(LWAuthStep)step {
    NSString *tag = nil;
    
    switch (step) {
        case LWAuthStepRegisterSelfie: {
            tag = @"register.camera.title.selfie";
            break;
        }
        case LWAuthStepRegisterIdentity: {
            tag = @"register.camera.title.idCard";
            break;
        }
        case LWAuthStepRegisterUtilityBill: {
            tag = @"register.camera.title.proofOfAddress";
            break;
        }
        default: {
            break;
        }
    }
    return (tag ? tag : @"");
}

@end
