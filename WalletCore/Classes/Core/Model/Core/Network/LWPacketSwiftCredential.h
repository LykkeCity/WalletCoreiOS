//
//  LWPacketSwiftCredential.h
//  LykkeWallet
//
//  Created by Bozidar Nikolic on 7/26/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"
@class LWSwiftCredentialsModel;
@interface LWPacketSwiftCredential : LWAuthorizePacket
    
// in
@property (copy, nonatomic) NSString *identity;

@end
