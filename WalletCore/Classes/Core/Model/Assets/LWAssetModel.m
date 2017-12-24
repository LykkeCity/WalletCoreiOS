//
//  LWAssetModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 02.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAssetModel.h"


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
        
        _blockchainDepositAddress = [json objectForKey:@"BcnDepositAddress"];
        
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
        
//        _hideDeposit=[[json objectForKey:@"HideDeposit"] boolValue];
        _hideWithdraw=[[json objectForKey:@"HideWithdraw"] boolValue];
        _bankCardDepositEnabled=[[json objectForKey:@"BankCardsDepositEnabled"] boolValue];
        _swiftDepositEnabled=[[json objectForKey:@"SwiftDepositEnabled"] boolValue];
        _blockchainDepositEnabled=[[json objectForKey:@"BlockchainDepositEnabled"] boolValue];
        _forwardWithdrawalBaseAssetId = json[@"ForwardBaseAsset"];
        
        _iconUrlString = json[@"IconUrl"];
        
        if([json[@"Blockchain"] isEqualToString:@"Bitcoin"]) {
            _blockchainType = BLOCKCHAIN_TYPE_BITCOIN;
        }
        else if([json[@"Blockchain"] isEqualToString:@"Ethereum"]) {
            _blockchainType = BLOCKCHAIN_TYPE_ETHEREUM;
        }
        else {
            _blockchainType = BLOCKCHAIN_TYPE_NONE;
        }

        
    }
    return self;
}

@end
