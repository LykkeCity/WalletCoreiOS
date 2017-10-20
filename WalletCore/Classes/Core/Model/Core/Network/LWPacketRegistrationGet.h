//
//  LWPacketRegistrationGet.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 21.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPersonalDataPacket.h"

@interface LWPacketRegistrationGet : LWPersonalDataPacket {
    
}
// out
@property (readonly, nonatomic) NSString *status;
@property (readonly, nonatomic) BOOL     isPinEntered;

@end
