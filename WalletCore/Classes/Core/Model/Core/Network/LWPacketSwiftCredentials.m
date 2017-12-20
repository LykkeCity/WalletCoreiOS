//
//  LWPacketSwiftCredentials.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 07/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketSwiftCredentials.h"
#import "LWKeychainManager.h"
#import "LWSwiftCredentialsModel.h"
#import "LWCache.h"

@implementation LWPacketSwiftCredentials

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    LWSwiftCredentialsModel *c=[LWSwiftCredentialsModel new];
    c=[[LWSwiftCredentialsModel alloc] init];
    c.bic=result[@"BIC"];
    c.accountNumber=result[@"AccountNumber"];
    c.accountName=result[@"AccountName"];
    c.purposeOfPayment=result[@"PurposeOfPayment"];
    c.bankAddress=result[@"BankAddress"];
    c.correspondentBank = result[@"CorrespondentAccount"] ?: @"";
    c.companyAddress=result[@"CompanyAddress"];
    
    _credentials = c;
    
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

- (NSString *)urlRelative {
    return [NSString stringWithFormat:@"SwiftCredentials/%@", _assetId];
}


@end
