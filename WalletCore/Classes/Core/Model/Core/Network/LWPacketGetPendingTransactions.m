//
//  LWPacketGetPendingTransactions.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 04/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketGetPendingTransactions.h"
#import "LWPrivateKeyManager.h"
#import "LWSignRequestModel.h"

@implementation LWPacketGetPendingTransactions

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    NSLog(@"%@", response);
    
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    for(NSDictionary *d in result[@"SignRequests"])
    {
        LWSignRequestModel *r=[[LWSignRequestModel alloc] initWithDictionary:d];
        [arr addObject:r];
    }
    
//    [[LWPrivateKeyManager shared] signEthereumTransactions:arr];
    
    
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

- (NSString *)urlRelative {
    return @"signRequest";
}

@end
