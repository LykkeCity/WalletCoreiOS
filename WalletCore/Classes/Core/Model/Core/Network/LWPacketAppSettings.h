//
//  LWPacketAppSettings.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@class LWAppSettingsModel;


@interface LWPacketAppSettings : LWAuthorizePacket {
    
}
// out
@property (copy, nonatomic) LWAppSettingsModel *appSettings;

@end
