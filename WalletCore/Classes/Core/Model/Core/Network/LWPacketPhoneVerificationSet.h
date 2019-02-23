//
//  LWPacketPhoneVerificationSet.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@interface LWPacketPhoneVerificationSet : LWAuthorizePacket {
    
}
// in
@property (copy, nonatomic) NSString *phone;

@end
