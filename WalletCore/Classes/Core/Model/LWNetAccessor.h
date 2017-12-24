//
//  LWNetAccessor.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 13.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+GDXObserver.h"
#import "LWPacket.h"
#import "Macro.h"


@interface LWNetAccessor : NSObject {
    
}

@property (strong, nonatomic) id caller;

#pragma mark - Common

- (void)sendPacket:(LWPacket *)packet;
- (void)sendPacket:(LWPacket *)packet info:(NSDictionary *)userInfo;

@end
