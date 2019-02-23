//
//  LWNetworkTemplate.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 07/04/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSURLRequest+ShowError.h"

typedef NS_ENUM(NSInteger, LWNetworkErrorType) {
    LWNetworkErrorTypeInvalidInputField = 0,
    LWNetworkErrorTypeInconsistentData = 1,
    LWNetworkErrorTypeNotAuthenticated = 2,
    LWNetworkErrorTypeInvalidUsernameOrPassword = 3,
    LWNetworkErrorTypeAssetNotFound = 4,
    LWNetworkErrorTypeNonEnoughFunds = 5,
    LWNetworkErrorTypeVersionNotSupported = 6,
    LWNetworkErrorTypeRuntimeProblem = 7,
    LWNetworkErrorTypeWrongConfirmationCode = 8,
    LWNetworkErrorTypeBackupWarning = 9,
    LWNetworkErrorTypeBackupRequired = 10,
    LWNetworkErrorTypeMaintananceMode = 11,
    
    LWNetworkErrorTypeNoData = 12,
    LWNetworkErrorTypeShouldOpenNewChannel = 13,
    LWNetworkErrorTypeShouldProvideNewTampPubKey = 14,
    LWNetworkErrorTypeShouldProcessOffchainRequest = 15,
    LWNetworkErrorTypeNoOffchainLiquidity = 16,
    
    LWNetworkErrorTypeAddressShouldBeGenerated = 20,
    
    LWNetworkErrorTypeExpiredAccessToken = 30,
    LWNetworkErrorTypeBadAccessToken = 31,
    LWNetworkErrorTypeNoEncodedMainKey = 32,
    LWNetworkErrorTypePreviousTransactionWereNotCompleted = 33,
    LWNetworkErrorTypeLimitationChackFailed = 34,
    LWNetworkErrorTypeLessThanMinimumOrderAmount = 64,
    
    LWNetworkErrorTypePendingDisclaimer = 70,
    
    LWNetworkErrorTypeBadRequest = 999
};

typedef NS_ENUM(NSInteger, LWNetworkHTTPCode) {
    LWNetworkHTTPCodeSuccess = 200,
    LWNetworkHTTPCodeRedirection = 300,
    LWNetworkHTTPCodeClientErrors = 400,
    LWNetworkHTTPCodeServerErrors = 500
};

static NSString *kMethodGET = @"GET";
static NSString *kMethodPOST = @"POST";

@interface LWNetworkTemplate : NSObject

@property (assign, nonatomic) BOOL shouldShowOffchainLiquidityError;

- (void)sendRequest:(NSURLRequest *)request completion:(void(^)(NSDictionary *response))completion;

- (id)sendRequest:(NSURLRequest *)request;
- (NSMutableURLRequest *)createRequestWithAPI:(NSString *)apiMethod
                                   httpMethod:(NSString *)httpMethod
                                getParameters:(NSDictionary *)getParams
                               postParameters:(NSDictionary *)postParams;

- (NSMutableURLRequest *)getRequestWithAPI:(NSString *)apiMethod params:(NSDictionary *)params;
- (NSMutableURLRequest *)postRequestWithAPI:(NSString *)apiMethod params:(NSDictionary *)params;

- (BOOL)showOffchainErrors;
- (BOOL)showKycErrors;

- (NSString *)baseURLPath;

@end
