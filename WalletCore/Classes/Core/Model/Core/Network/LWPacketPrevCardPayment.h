//
//  LWPacketPrevCardPayment.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 02/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"
@class LWPersonalDataModel;

@interface LWPacketPrevCardPayment : LWAuthorizePacket

@property (strong, nonatomic) LWPersonalDataModel *lastPaymentPersonalData;

@end
