//
//  LWSwiftCashOutDetailsModel.m
//  LykkeWallet
//
//  Created by vsilux on 20/10/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWSwiftCashOutDetailsModel.h"

@implementation LWSwiftCashOutDetailsModel

#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
  self = [super initWithJSON:json];
  if (self) {
    _amount              = [json[@"Amount"] integerValue];
    _asset               = json[@"Asset"] ? json[@"Asset"] : @"";
    _bic                 = json[@"Bic"] ? json[@"Bic"] : @"";
    _accountNumber       = json[@"AccNumber"] ? json[@"AccNumber"] : @"";
    _accountName         = json[@"AccName"] ? json[@"AccName"] : @"";
    _bankName            = json[@"BankName"] ? json[@"BankName"] : @"";
    _city                = json[@"AccHolderCity"] ? json[@"AccHolderCity"] : @"";
    _country             = json[@"AccHolderCountry"] ? json[@"AccHolderCountry"] : @"";
    _zipCode             = json[@"AccHolderZipCode"] ? json[@"AccHolderZipCode"] : @"";
    _accountHolderAdress = json[@"AccHolderAddress"] ? json[@"AccHolderAddress"] : @"";
  }
  return self;
}


@end
