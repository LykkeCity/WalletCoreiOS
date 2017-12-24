//
//  LWBaseHistoryItemType.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 10.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, LWHistoryItemType) {
    //LWHistoryItemTypeMarket,
    LWHistoryItemTypeTrade,
    LWHistoryItemTypeCashInOut,
    LWHistoryItemTypeTransfer,
    LWHistoryItemTypeSettle
};


@interface LWBaseHistoryItemType : NSObject<NSCopying> {
    
}


#pragma mark - Properties

@property (assign, nonatomic) LWHistoryItemType  historyType;
@property (copy,   nonatomic) NSString          *identity;
@property (copy,   nonatomic) NSString          *asset;
@property (copy,   nonatomic) NSString          *assetId;
@property (copy,   nonatomic) NSDate            *dateTime;
@property (copy, nonatomic) NSString *blockchainHash;
@property (copy, nonatomic) NSString *iconId;

@property (copy, nonatomic) NSString *addressFrom;
@property (copy, nonatomic) NSString *addressTo;

@property (copy, nonatomic) NSNumber *volume;


@property BOOL isSettled;
@property BOOL isOffchain;

@end
