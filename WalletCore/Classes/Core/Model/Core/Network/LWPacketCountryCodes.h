//
//  LWPacketCountryCodes.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"
#import "LWCountryModel.h"


@interface LWPacketCountryCodes : LWAuthorizePacket {
    
}


// out
@property (readonly, nonatomic) NSArray *countries;
@property (readonly, nonatomic) LWCountryModel *ipLocatedCountry;

@end
