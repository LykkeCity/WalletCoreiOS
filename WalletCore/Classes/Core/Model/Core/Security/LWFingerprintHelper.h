//
//  LWFingerprintHelper.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 08.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^fingerpintBlock)();


@interface LWFingerprintHelper : NSObject {
    
}


#pragma mark - General

+ (BOOL)isFingerprintAvailable;

+ (void)validateFingerprintTitle:(NSString *)title ok:(fingerpintBlock)okBlock bad:(fingerpintBlock)badBlock unavailable:(fingerpintBlock)unavailableBlock;

@end
