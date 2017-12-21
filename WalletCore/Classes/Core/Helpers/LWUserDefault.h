//
//  LWUserDefault.h
//  LykkeWallet
//
//  Created by vsilux on 08/11/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LWMainScreenData;

@interface LWUserDefault : NSObject

+ (instancetype)instance;

@property (nonatomic, getter = isNotFirstRun) BOOL notFirstRun;
@property (nonatomic, getter = isIntroductionShown) BOOL introductionShown;
@property (nonatomic, getter = isMarginTermsOfUseAgreed) BOOL marginTermsOfUseAgreed;
@property (nonatomic) BOOL lkk2yDisclaimerAgreed;
@property (nonatomic) BOOL showOrderConfirmation;

@property (nonatomic) NSString *selectedCFDWatchListId;
@property (nonatomic) NSString *selectedSPOTWatchListId;
@property (nonatomic) NSString *currentMarginalAccountId;

@property (nonatomic) NSDate *phoneCodesLastModifiedDate;
@property (nonatomic) NSDate *phoneCodesLastLoadDate;

- (void)reset;

- (void)storeLastEnteredAmount:(double)amount forPositionWith:(NSString *)assetId;
- (double)lastEnteredAmountForPositionWith:(NSString *)assetId;

- (void)storeTopBarPreviousChoice:(NSString *)choice withSubKey:(NSString *)subKey;
- (NSString *)topBarPreviousChoiceWithSubKey:(NSString *)subKey;

@end
