//
//  LWPacketPhoneVerificationGet.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@interface LWPacketPhoneVerificationGet : LWAuthorizePacket {
    
}
// in
@property (copy, nonatomic) NSString *phone;
@property (copy, nonatomic) NSString *code;
// out
@property (readonly, nonatomic) BOOL isPassed;

@end
