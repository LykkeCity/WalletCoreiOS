//
//  LWPacketBankCards.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 31.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacketBankCards.h"
#import "LWBankCardsAdd.h"


@implementation LWPacketBankCards


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
}

- (NSString *)urlRelative {
    return @"BankCards";
}

- (NSDictionary *)params {
    return @{@"BankNumber" : self.addCardData.bankNumber,
             @"Name"       : self.addCardData.name,
             @"Type"       : self.addCardData.type,
             @"MonthTo"    : self.addCardData.monthTo,
             @"YearTo"     : self.addCardData.yearTo,
             @"Cvc"        : self.addCardData.cvc};
}

@end
