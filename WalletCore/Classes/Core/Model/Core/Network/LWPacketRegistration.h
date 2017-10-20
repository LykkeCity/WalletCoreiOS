//
//  LWPacketRegistration.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 11.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacket.h"
#import "LWRegistrationData.h"


@interface LWPacketRegistration : LWPacket {
    
}
// in
@property (copy, nonatomic) LWRegistrationData *registrationData;
// out
@property (copy, nonatomic) NSString *token;

@end
