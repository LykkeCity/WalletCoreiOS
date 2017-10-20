//
//  LWPacketTransactions.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 10.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketTransactions.h"
#import "LWTransactionsModel.h"
#import "LWHistoryManager.h"


@implementation LWPacketTransactions


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
//    NSDictionary *dict=[LWHistoryManager convertHistoryArrayToDict:result];
    
    _model = [[LWTransactionsModel alloc] initWithJSON:result];
}

- (NSString *)urlRelative {
    if (self.assetId && ![self.assetId isKindOfClass:[NSNull class]]) {
        return [NSString stringWithFormat:@"Transactions?assetId=%@", self.assetId];
    }
    return @"Transactions?assetId=null";
}

//- (NSString *)urlRelative {
//    if (self.assetId && ![self.assetId isKindOfClass:[NSNull class]]) {
//        return [NSString stringWithFormat:@"History?assetId=%@", self.assetId];
//    }
//    return @"History?assetId=null";
//}


- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
