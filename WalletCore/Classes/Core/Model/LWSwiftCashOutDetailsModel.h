//
//  LWSwiftCashOutDetailsModel.h
//  LykkeWallet
//
//  Created by vsilux on 20/10/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"

@interface LWSwiftCashOutDetailsModel : LWJSONObject

@property (readonly, nonatomic) NSUInteger amount;
@property (readonly, nonatomic) NSString  *asset;
@property (readonly, nonatomic) NSString  *bic;
@property (readonly, nonatomic) NSString  *accountNumber;
@property (readonly, nonatomic) NSString  *accountName;
@property (readonly, nonatomic) NSString  *bankName;
@property (readonly, nonatomic) NSString  *city;
@property (readonly, nonatomic) NSString  *country;
@property (readonly, nonatomic) NSString  *zipCode;
@property (readonly, nonatomic) NSString  *accountHolderAdress;

@end
