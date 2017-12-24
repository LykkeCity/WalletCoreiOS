//
//  LWPacketKYCForAsset.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@interface LWPacketKYCForAsset : LWAuthorizePacket

@property (strong, nonatomic) NSString *assetId;
@property (strong, nonatomic) NSString *userKYCStatus;
@property BOOL kycNeeded;

@end
