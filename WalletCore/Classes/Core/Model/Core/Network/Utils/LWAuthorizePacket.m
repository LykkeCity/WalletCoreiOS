//
//  LWAuthorizePacket.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 14.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"
#import "LWKeychainManager.h"


@implementation LWAuthorizePacket


#pragma mark - LWPacket

- (NSDictionary *)headers {
    NSString *token = [LWKeychainManager instance].token;
    
    
    NSMutableDictionary *dict=[[super headers] mutableCopy];
    
    
    if (token) {
        dict[@"Authorization"]=[NSString stringWithFormat:@"Bearer %@", token];
//        return @{@"Authorization" : [NSString stringWithFormat:@"Bearer %@", token]};
    }
    return dict;
}

@end
