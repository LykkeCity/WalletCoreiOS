//
//  LWPacketKYCForAsset.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketKYCForAsset.h"

@implementation LWPacketKYCForAsset
- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    self.kycNeeded=[result[@"KycNeeded"] boolValue];
    self.userKYCStatus=result[@"UserKycStatus"];
    
    
}

- (NSString *)urlRelative {
    return [NSString stringWithFormat:@"KycForAsset/%@", self.assetId];
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
