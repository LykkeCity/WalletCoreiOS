//
//  LWPacketSettleForwardWithdraw.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 21/03/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketSettleForwardWithdraw.h"
#import "LWAssetModel.h"
#import "LWPrivateKeyManager.h"

@implementation LWPacketSettleForwardWithdraw

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    NSLog(@"%@", response);
    
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}

-(NSDictionary *) params {
    
    //Transactions are signed locally
//    return @{@"AssetId": _asset.identity, @"Amount": @(_amount), @"PrivateKey":[LWPrivateKeyManager shared].wifPrivateKeyLykke};
    return @{@"AssetId": _asset.identity, @"Amount": @(_amount)};
}

- (NSString *)urlRelative {
    
    
    NSString *urlStr = @"operations/ForwardWithdrawal";
    
    return urlStr;
}

@end
