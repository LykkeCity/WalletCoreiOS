//
//  LWPacketSettingSignOrder.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@interface LWPacketSettingSignOrder : LWAuthorizePacket {
    
}
// in
@property (assign, nonatomic) BOOL shouldSignOrder;
// out
@property (readonly, nonatomic) BOOL signOrderBeforeGo;

@end
