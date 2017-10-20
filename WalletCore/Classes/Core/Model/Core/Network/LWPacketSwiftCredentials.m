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
    
    NSArray *arr=result.allKeys;
    
    NSMutableDictionary *swiftCredentialsDict=[[NSMutableDictionary alloc] init];
    for(NSString *key in arr)
    {
        LWSwiftCredentialsModel *c=[LWSwiftCredentialsModel new];
        c=[[LWSwiftCredentialsModel alloc] init];
        c.bic=result[key][@"BIC"];
        c.accountNumber=result[key][@"AccountNumber"];
        c.accountName=result[key][@"AccountName"];
        c.purposeOfPayment=result[key][@"PurposeOfPayment"];
        c.bankAddress=result[key][@"BankAddress"];
        c.companyAddress=result[key][@"CompanyAddress"];
        swiftCredentialsDict[key]=c;
    }
    
    [LWCache instance].swiftCredentialsDict=swiftCredentialsDict;;
    
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

- (NSString *)urlRelative {
    return [NSString stringWithFormat:@"SwiftCredentials"];
}


@end
