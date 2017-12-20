//
//  LWAssetModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 02.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAssetModel.h"

static NSString *kErc20Token = @"Erc20Token";

NSString * const kBTC_ID = @"BTC";
NSString * const kETH_ID = @"ETH";
NSString * const kETH_GUID = @"e58aa37d-dd46-4bdb-bac1-a6d0d44e6dc9";

@implementation LWAssetModel


#pragma mark - Root

+ (NSString *)assetByIdentity:(NSString *)identity fromList:(NSArray *)list {
  if (list && list.count > 0) {
    for (LWAssetModel *item in list) {
      if ([item.identity isEqualToString:identity]) {
        return item.displayId;
      }
    }
  }
  return identity; // requirement - if not found - show identity
}


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
  self = [super initWithJSON:json];
  if (self) {
    _identity = [json objectForKey:@"Id"];
    _name     = [json objectForKey:@"Name"];
    if(_name == nil) {
      _name = @"";
    }
    _accuracy = [json objectForKey:@"Accuracy"];
    _symbol   = [json objectForKey:@"Symbol"];
    _issuerId = [json objectForKey:@"IdIssuer"];
    _categoryId = [json objectForKey:@"CategoryId"];
    
    _displayId = [json objectForKey:@"DisplayId"];
    
    _fullName = [[json objectForKey:@"Description"] objectForKey:@"FullName"];
    
    self.blockchainDepositAddress = [[json objectForKey:@"BcnDepositAddress"] copy];
    
    _visaDeposit = [[json objectForKey:@"VisaDeposit"] boolValue];
    _swiftDeposit = [[json objectForKey:@"SwiftDeposit"] boolValue];
    _blockchainDeposit = [[json objectForKey:@"BlockchainDeposit"] boolValue];
    _buyScreen = [[json objectForKey:@"BuyScreen"] boolValue];
    
    _swiftWithdraw = [[json objectForKey:@"SwiftWithdrawal"] boolValue];
    _blockchainWithdraw = [[json objectForKey:@"BlockchainWithdrawal"] boolValue];
    
    _sellScreen = [[json objectForKey:@"SellScreen"] boolValue];
    
    _crossChainWithdrawal = [[json objectForKey:@"CrosschainWithdrawal"] boolValue];
    if(_crossChainWithdrawal) {
      _blockchainWithdraw = true;
    }
    _forwardWithdrawal = [[json objectForKey:@"ForwardWithdrawal"] boolValue];
    _forwardFrozenDays = [[json objectForKey:@"ForwardFrozenDays"] intValue];
    _forwardWithdrawalMemorandumUrl = json[@"ForwardMemoUrl"];
    
    _hideWithdraw = [[json objectForKey:@"HideWithdraw"] boolValue];
    _bankCardDepositEnabled = [[json objectForKey:@"BankCardsDepositEnabled"] boolValue];
    _swiftDepositEnabled = [[json objectForKey:@"SwiftDepositEnabled"] boolValue];
    _blockchainDepositEnabled = [[json objectForKey:@"BlockchainDepositEnabled"] boolValue];
    _forwardWithdrawalBaseAssetId = json[@"ForwardBaseAsset"];
    
    self.assetType = [json[@"AssetType"] copy];
    
    _iconUrlString = json[@"IconUrl"];
    
    _trusted = [json[@"IsTrusted"] boolValue];
    if([json[@"Blockchain"] isEqualToString:@"Bitcoin"]) {
      _blockchainType = LWBlockchainTypeBitcoint;
    } else if([json[@"Blockchain"] isEqualToString:@"Ethereum"]) {
      _blockchainType = LWBlockchainTypeEthereum;
    } else {
      _blockchainType = LWBlockchainTypeNone;
    }
  }
  return self;
}

- (BOOL)isErc20 {
  return [self.assetType isEqualToString:kErc20Token];
}

@end
