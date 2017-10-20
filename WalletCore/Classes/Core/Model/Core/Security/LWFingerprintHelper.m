//
//  LWFingerprintHelper.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 08.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWFingerprintHelper.h"
#import <LocalAuthentication/LocalAuthentication.h>


@implementation LWFingerprintHelper


#pragma mark - General

+ (BOOL)isFingerprintAvailable {
    LAContext *laContext = [[LAContext alloc] init];
    NSError *authError = nil;
    if ([laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        return (authError == nil);
    }
    return NO;
}

+ (void)validateFingerprintTitle:(NSString *)title ok:(fingerpintBlock)okBlock bad:(fingerpintBlock)badBlock unavailable:(fingerpintBlock)unavailableBlock {
    if ([LWFingerprintHelper isFingerprintAvailable]) {
        LAContext *laContext = [[LAContext alloc] init];
        [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:title
                            reply:^(BOOL success, NSError *error) {
                                if (success) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        if (okBlock) {
                                            okBlock();
                                        }
                                    });
                                } else {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        if (badBlock) {
                                            badBlock();
                                        }
                                    });
                                }
                            }];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (unavailableBlock) {
                unavailableBlock();                
            }
        });
    }
}

@end
