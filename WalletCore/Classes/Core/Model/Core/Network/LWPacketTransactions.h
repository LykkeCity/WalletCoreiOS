//
//  LWPacketTransactions.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 10.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@class LWTransactionsModel;


@interface LWPacketTransactions : LWAuthorizePacket {
    
}
// in
@property (assign, nonatomic) NSString *assetId;
// out
@property (readonly, nonatomic) LWTransactionsModel* model;

@end
