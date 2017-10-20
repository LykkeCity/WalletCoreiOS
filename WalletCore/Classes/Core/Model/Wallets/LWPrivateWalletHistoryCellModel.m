//
//  LWPrivateWalletHistoryCellModel.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 24/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateWalletHistoryCellModel.h"
#import "NSString+Date.h"

@implementation LWPrivateWalletHistoryCellModel

-(id) initWithDict:(NSDictionary *) d
{
    self=[super init];
    
    self.amount=@(fabs([d[@"Amount"] doubleValue]));
    self.assetId=d[@"AssetId"];
    self.date=[d[@"DateTime"] toDate];
    self.baseAssetAmount=@(fabs([d[@"AmountInBase"] doubleValue]));
    if([d[@"Amount"] doubleValue]>0)
        self.type=LWPrivateWalletTransferTypeReceive;
    else
        self.type=LWPrivateWalletTransferTypeSend;
    
    self.baseAssetId=d[@"BaseAssetId"];
    
    
//    self.amount=@(20);
//    self.assetId=@"BTC";
//    self.baseAssetAmount=@(1000);
//    self.type=LWPrivateWalletTransferTypeSend;
//    
//    self.date=[NSDate date];
    
    return self;
}

@end
