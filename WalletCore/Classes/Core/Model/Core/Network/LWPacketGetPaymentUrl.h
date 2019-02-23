//
//  LWPacketGetPaymentUrl.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 26/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketGetPaymentUrl : LWAuthorizePacket

@property (strong, nonatomic) NSDictionary *parameters;
@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) NSString *successUrl;
@property (strong, nonatomic) NSString *failUrl;

@property (strong, nonatomic) NSString *reloadRegex;
@end
