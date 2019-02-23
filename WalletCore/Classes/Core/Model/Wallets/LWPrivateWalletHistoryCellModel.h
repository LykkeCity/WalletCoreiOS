//
//  LWPrivateWalletHistoryCellModel.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 24/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LWPrivateWalletTransferType) {
    LWPrivateWalletTransferTypeUnknown = 0,
    LWPrivateWalletTransferTypeSend,
    LWPrivateWalletTransferTypeReceive
};


@interface LWPrivateWalletHistoryCellModel : NSObject

-(id) initWithDict:(NSDictionary *) dict;

@property (strong, nonatomic) NSString *assetId;
@property LWPrivateWalletTransferType type;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSNumber *amount;
@property (strong, nonatomic) NSNumber *baseAssetAmount;
@property (strong, nonatomic) NSString *baseAssetId;


@end
