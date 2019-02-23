//
//  LWPKTransferModel.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWPrivateWalletModel.h"
#import "LWPrivateWalletAssetModel.h"


@interface LWPKTransferModel : NSObject

@property (strong, nonatomic) LWPrivateWalletModel *sourceWallet;
@property (strong, nonatomic) NSString *destinationAddress;
@property (strong, nonatomic) LWPrivateWalletAssetModel *asset;
@property (strong, nonatomic) NSNumber *amount;

@end
