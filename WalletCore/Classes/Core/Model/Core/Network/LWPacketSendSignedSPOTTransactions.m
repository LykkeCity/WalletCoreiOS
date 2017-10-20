//
//  LWPacketSendSignedSPOTTransactions.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 03/04/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketSendSignedSPOTTransactions.h"

@implementation LWPacketSendSignedSPOTTransactions

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    
    
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}

-(NSDictionary *) params {
    return @{@"Transactions":_transactions};
}


- (NSString *)urlRelative {
    
    
    NSString *urlStr = @"operations/unsignedTransactions";
    
    return urlStr;
}


@end
