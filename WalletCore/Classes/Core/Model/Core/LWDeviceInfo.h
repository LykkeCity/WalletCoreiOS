//
//  LWDeviceInfo.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 23.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Macro.h"


@interface LWDeviceInfo : NSObject {
    
}

SINGLETON_DECLARE


#pragma mark - Common

- (NSString *)clientInfo;

@end
