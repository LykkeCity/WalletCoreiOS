//
//  LWPacketBuySellAsset.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@class LWAssetDealModel;


typedef NS_ENUM(NSInteger, LWAssetDealType) {
    LWAssetDealTypeUnknown = 0,
    LWAssetDealTypeSell,
    LWAssetDealTypeBuy
};


@interface LWPacketBuySellAsset : LWAuthorizePacket {
    
}
// in
@property (copy, nonatomic) NSString *baseAsset;
@property (copy, nonatomic) NSString *assetPair;
@property (copy, nonatomic) NSNumber *volume;
@property (copy, nonatomic) NSString *rate;
// out
@property (readonly, nonatomic) LWAssetDealModel *deal;

// general
//@property (assign, nonatomic) LWAssetDealType dealType;

@end
