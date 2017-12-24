//
//  LWPacketSendSignedTransaction.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 05/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@class LWSignRequestModel;

@interface LWPacketSendSignedTransaction : LWAuthorizePacket

@property (strong, nonatomic) LWSignRequestModel *signRequest;

@end
