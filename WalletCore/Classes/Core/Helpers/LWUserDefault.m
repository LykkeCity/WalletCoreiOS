//
//  LWUserDefault.m
//  LykkeWallet
//
//  Created by vsilux on 08/11/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWUserDefault.h"
#import <WalletCore/WalletCore-Swift.h>

static NSString * const kCFDSelectedWatchListIdKey = @"SelectedCFDWatchListId";
static NSString * const kSPOTSelectedWatchListIdKey = @"SelectedSPOTWatchListId";
static NSString * const kCurrentMarginalAccountIdKey = @"CurrentMarginalAccountId";
static NSString * const kCountryPhoneCodesLastModifiedKey = @"CountryPhoneCodesLastModified";
static NSString * const kCountryPhoneCodesLastLoadedKey = @"CountryPhoneCodesLastLoaded";
static NSString * const kIntroductionShownKey = @"IntroductionShown";
static NSString * const kFirstRunKey = @"FirstRun";
static NSString * const kMarginTermsOfUseAgreedKey = @"MarginTermsOfUseAgreed";
static NSString * const kUserLastEnteredAmountForPosition = @"UserLastEnteredAmountForPosition";
static NSString * const kTopBarPrevChoice = @"TopBarPrevChoice";
static NSString * const kLKK2YDisclaimerAgreed = @"com.lykke.lkk2yDisclaimerAgreed";
static NSString * const kShowOrderConfirmationKey = @"com.lykke.OrderSummaryPopupContainer.shouldshow";

@interface LWUserDefault ()

@property (strong, nonatomic) NSUserDefaults *userDefaults;

@end

@implementation LWUserDefault

+ (instancetype)instance {
  static id sharedInstance = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  
  return sharedInstance;
}

- (void)reset {
	self.lkk2yDisclaimerAgreed = NO;
}

#pragma mark - Internal

- (instancetype)init {
  self = [super init];
  
  if (self) {
    self.userDefaults = [NSUserDefaults standardUserDefaults];
  }
  
  return self;
}

- (void)setObject:(id)anObject forKey:(NSString *)key {
  if (anObject == nil) {
    [self.userDefaults removeObjectForKey:key];
  } else {
    [self.userDefaults setObject:anObject forKey:key];
  }
}

#pragma mark - Properties

- (BOOL)isIntroductionShown {
  return [self.userDefaults boolForKey:kIntroductionShownKey];
}

- (void)setIntroductionShown:(BOOL)introductionShown {
  [self.userDefaults setBool:introductionShown forKey:kIntroductionShownKey];
}

- (BOOL)isNotFirstRun {
  return [self.userDefaults boolForKey:kFirstRunKey];
}

- (void)setNotFirstRun:(BOOL)notFirstRun {
  [self.userDefaults setBool:notFirstRun forKey:kFirstRunKey];
}

- (BOOL)isMarginTermsOfUseAgreed {
  return [self.userDefaults boolForKey:kMarginTermsOfUseAgreedKey];
}

- (void)setMarginTermsOfUseAgreed:(BOOL)marginTermsOfUseAgreed {
  [self.userDefaults setBool:marginTermsOfUseAgreed forKey:kMarginTermsOfUseAgreedKey];
}

- (void)setLkk2yDisclaimerAgreed:(BOOL)lkk2yDisclaimerAgreed {
  [self.userDefaults setBool:lkk2yDisclaimerAgreed forKey:kLKK2YDisclaimerAgreed];
}

- (BOOL)lkk2yDisclaimerAgreed {
  return [self.userDefaults boolForKey:kLKK2YDisclaimerAgreed];
}

- (BOOL)showOrderConfirmation {
  id value = [self.userDefaults objectForKey:kShowOrderConfirmationKey];
  if (value == nil) {
    return YES;
  } else {
    return [value boolValue];
  }
}

- (void)setShowOrderConfirmation:(BOOL)showOrderConfirmation {
  [self.userDefaults setBool:showOrderConfirmation forKey:kShowOrderConfirmationKey];
}

- (NSString *)selectedCFDWatchListId {
  return [self.userDefaults stringForKey:kCFDSelectedWatchListIdKey];
}

- (void)setSelectedCFDWatchListId:(NSString *)selectedCFDWatchListId {
  [self setObject:selectedCFDWatchListId forKey:kCFDSelectedWatchListIdKey];
}

- (NSString *)selectedSPOTWatchListId {
  return [self.userDefaults stringForKey:kSPOTSelectedWatchListIdKey];
}

- (void)setSelectedSPOTWatchListId:(NSString *)selectedSPOTWatchListId {
  [self setObject:selectedSPOTWatchListId forKey:kSPOTSelectedWatchListIdKey];
}

- (NSString *)currentMarginalAccountId {
  return [self.userDefaults stringForKey:kCurrentMarginalAccountIdKey];
}

- (void)setCurrentMarginalAccountId:(NSString *)currentMarginalAccountId {
  [self setObject:currentMarginalAccountId forKey:kCurrentMarginalAccountIdKey];
}

- (NSDate *)phoneCodesLastModifiedDate {
  return [self.userDefaults objectForKey:kCountryPhoneCodesLastModifiedKey];
}

- (void)setPhoneCodesLastModifiedDate:(NSDate *)phoneCodesLastModifiedDate {
  [self setObject:phoneCodesLastModifiedDate forKey:kCountryPhoneCodesLastModifiedKey];
}

- (NSDate *)phoneCodesLastLoadDate {
  return [self.userDefaults objectForKey:kCountryPhoneCodesLastLoadedKey];
}

- (void)setPhoneCodesLastLoadDate:(NSDate *)phoneCodesLastLoadDate {
  [self setObject:phoneCodesLastLoadDate forKey:kCountryPhoneCodesLastLoadedKey];
}

- (void)storeLastEnteredAmount:(double)amount forPositionWith:(NSString *)assetId {
	[self.userDefaults setDouble:amount forKey:[kUserLastEnteredAmountForPosition stringByAppendingString:assetId]];
}

- (double)lastEnteredAmountForPositionWith:(NSString *)assetId {
	return [self.userDefaults doubleForKey:[kUserLastEnteredAmountForPosition stringByAppendingString:assetId]];
}

- (void)storeTopBarPreviousChoice:(NSString *)choice withSubKey:(NSString *)subKey {
	[self.userDefaults setObject:choice forKey:[kTopBarPrevChoice stringByAppendingString:subKey]];
}

- (NSString *)topBarPreviousChoiceWithSubKey:(NSString *)subKey {
	return [self.userDefaults objectForKey:[kTopBarPrevChoice stringByAppendingString:subKey]];
}

@end
