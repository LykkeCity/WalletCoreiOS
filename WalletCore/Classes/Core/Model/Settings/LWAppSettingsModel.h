//
//  LWAppSettingsModel.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"


@class LWAssetModel;


@interface LWAppSettingsModel : LWJSONObject {
    
}


#pragma mark - Properties

@property (readonly, nonatomic) NSString     *depositUrl;
@property (readonly, nonatomic) NSNumber     *rateRefreshPeriod;
@property (readonly, nonatomic) LWAssetModel *baseAsset;
@property (readonly, nonatomic) BOOL          shouldSignOrders;
@property (readonly, nonatomic) BOOL          debugMode;

@end
