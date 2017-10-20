//
//  LWPrivateKeyOwnershipMessage.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 22/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPrivateKeyOwnershipMessage : LWAuthorizePacket

@property (copy, nonatomic) NSString *ownershipMessage;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *signature;

@property BOOL confirmedOwnership;

@end
