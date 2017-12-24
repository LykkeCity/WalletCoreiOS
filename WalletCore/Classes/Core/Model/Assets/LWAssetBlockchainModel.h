//
//  LWAssetBlockchainModel.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 08.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"


@interface LWAssetBlockchainModel : LWJSONObject {
    
}


#pragma mark - Properties

@property (readonly, nonatomic) NSString *identity;
@property (readonly, nonatomic) NSString *date;
@property (readonly, nonatomic) NSNumber *confirmations;
@property (readonly, nonatomic) NSString *block;
@property (readonly, nonatomic) NSNumber *height;
@property (readonly, nonatomic) NSString *senderId;
@property (readonly, nonatomic) NSString *assetId;
@property (readonly, nonatomic) NSNumber *quantity;
@property (readonly, nonatomic) NSString *url;

@end
