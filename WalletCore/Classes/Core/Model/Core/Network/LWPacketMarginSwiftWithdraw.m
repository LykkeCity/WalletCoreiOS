//
//  LWPacketMarginSwiftWithdraw.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 29/06/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketMarginSwiftWithdraw.h"

@implementation LWPacketMarginSwiftWithdraw

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}

-(NSDictionary *) params {
    return _credentials;
}

- (NSString *)urlRelative {
    return @"MarginTrading/cashOutSwift";
}

@end
