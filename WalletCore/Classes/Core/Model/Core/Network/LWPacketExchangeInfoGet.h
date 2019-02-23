//
//  LWPacketExchangeInfoGet.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 16.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@class LWExchangeInfoModel;


@interface LWPacketExchangeInfoGet : LWAuthorizePacket {
    
}
// in
@property (assign, nonatomic) NSString *exchangeId;
// out
@property (readonly, nonatomic) LWExchangeInfoModel *model;

@end
