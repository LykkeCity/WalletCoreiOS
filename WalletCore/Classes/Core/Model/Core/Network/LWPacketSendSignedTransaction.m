//
//  LWPacketSendSignedTransaction.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 05/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketSendSignedTransaction.h"
#import "LWSignRequestModel.h"
#import "LWPrivateKeyManager.h"

@implementation LWPacketSendSignedTransaction

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    NSLog(@"%@", response);
    
    [[LWPrivateKeyManager shared] signatureSent];
    
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}

-(NSDictionary *) params
{
    return @{@"RequestId":_signRequest.requestId, @"MultisigAddress":_signRequest.address, @"Sign":_signRequest.signature};
}

- (NSString *)urlRelative {
    return @"signRequest";
}


@end
