//
//  LWPacketRestrictedCountries.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 14.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@interface LWPacketRestrictedCountries : LWAuthorizePacket {
    
}
// out
@property (readonly, nonatomic) NSArray *countries;

@end
