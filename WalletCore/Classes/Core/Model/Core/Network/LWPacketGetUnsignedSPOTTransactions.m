//
//  LWPacketGetUnsignedSPOTTransactions.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 03/04/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketGetUnsignedSPOTTransactions.h"

@implementation LWPacketGetUnsignedSPOTTransactions

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if([result isKindOfClass:[NSArray class]]) {
        _transactions = (NSArray *)result;
    }
    
    
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}



- (NSString *)urlRelative {
    
    
    NSString *urlStr = @"operations/unsignedTransactions";
    
    return urlStr;
}

@end
