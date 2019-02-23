//
//  LWPacketEmailVerificationGet.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 03.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacket.h"


@interface LWPacketEmailVerificationGet : LWPacket {
    
}
// in
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *accessToken;
@property (copy, nonatomic) NSString *code;
// out
@property (readonly, nonatomic) BOOL isPassed;

@end
