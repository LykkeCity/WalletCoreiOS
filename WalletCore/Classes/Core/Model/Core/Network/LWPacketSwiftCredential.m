//
//  LWPacketSwiftCredential.m
//  LykkeWallet
//
//  Created by Bozidar Nikolic on 7/26/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketSwiftCredential.h"
#import "LWKeychainManager.h"
#import "LWSwiftCredentialsModel.h"
#import "LWCache.h"


@implementation LWPacketSwiftCredential
    
- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
//    NSArray *arr=result.allKeys;
    
    NSMutableDictionary *swiftCredentialsDict=[[NSMutableDictionary alloc] init];
//    for(NSString *key in arr)
//    {
        LWSwiftCredentialsModel *c=[LWSwiftCredentialsModel new];
        c=[[LWSwiftCredentialsModel alloc] init];
        c.bic=result[@"BIC"];
        c.accountNumber=result[@"AccountNumber"];
        c.accountName=result[@"AccountName"];
        c.purposeOfPayment=result[@"PurposeOfPayment"];
        c.bankAddress=result[@"BankAddress"];
        c.companyAddress=result[@"CompanyAddress"];
        swiftCredentialsDict[self.identity]=c;
//    }
    
    [LWCache instance].swiftCredentialsDict=swiftCredentialsDict;;
    
}
    
- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}
    
- (NSString *)urlRelative {
    return [NSString stringWithFormat:@"SwiftCredentials/%@", self.identity];
}

@end
