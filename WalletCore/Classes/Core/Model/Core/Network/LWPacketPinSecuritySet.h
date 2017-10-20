//
//  LWPacketPinSecuritySet.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 13.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@interface LWPacketPinSecuritySet : LWAuthorizePacket {
    
}
// in
@property (copy, nonatomic) NSString *pin;

@end
