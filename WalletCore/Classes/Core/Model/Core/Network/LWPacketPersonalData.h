//
//  LWPacketPersonalData.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 26.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@class LWPersonalDataModel;


@interface LWPacketPersonalData : LWAuthorizePacket {
    
}
// out
@property (copy, nonatomic) LWPersonalDataModel *data;

@end
