//
//  LWPacketSwiftCredentials.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 07/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"
@class LWSwiftCredentialsModel;
@interface LWPacketSwiftCredentials : LWAuthorizePacket

@property (strong, nonatomic) NSString *assetId;
@property (strong, nonatomic) LWSwiftCredentialsModel *credentials;

@end
