//
//  LWPacketPrevCardPayment.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 02/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketPrevCardPayment.h"
#import "LWPersonalDataModel.h"
#import "LWCache.h"

@implementation LWPacketPrevCardPayment

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    self.lastPaymentPersonalData=[[LWPersonalDataModel alloc] initWithJSON:result];
    [LWCache instance].lastCardPaymentData=self.lastPaymentPersonalData;
}

- (NSString *)urlRelative {
    return @"BankCardPaymentUrlFormValues";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}


@end
