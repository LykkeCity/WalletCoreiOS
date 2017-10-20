//
//  LWPacketGraphPeriods.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 12/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@class LWGraphPeriodModel;

@interface LWPacketGraphPeriods : LWAuthorizePacket


@property (strong, nonatomic) NSArray *periods;
@property (strong, nonatomic) LWGraphPeriodModel *lastSelectedPeriod;

@end
