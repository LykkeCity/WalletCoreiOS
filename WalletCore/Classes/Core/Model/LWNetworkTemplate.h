//
//  LWNetworkTemplate.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 07/04/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSURLRequest+ShowError.h"

typedef enum {
    REQUEST_ERROR_INVALID_INPUT_FIELD = 0,
    REQUEST_ERROR_INCONSISTENT_DATA = 1,
    REQUEST_ERROR_NOT_AUTHENTICATED = 2,
    REQUEST_ERROR_INVALID_USERNAME_OR_PASSWORD = 3,
    REQUEST_ERROR_ASSET_NOT_FOUND = 4,
    REQUEST_ERROR_NOT_ENOUGH_FUNDS = 5,
    REQUEST_ERROR_VERSION_NOT_SUPPORTED = 6,
    REQUEST_ERROR_RUNTIME_PROBLEM = 7,
    REQUEST_ERROR_WRONG_CONFIRMATION_CODE = 8,
    REQUEST_ERROR_BACKUP_WARNING = 9,
    REQUEST_ERROR_BACKUP_REQUIRED = 10,
    REQUEST_ERROR_MAINTANANCE_MODE = 11,

    REQUEST_ERROR_NO_DATA = 12,
    REQUEST_ERROR_SHOULD_OPEN_NEW_CHANNEL = 13,
    REQUEST_ERROR_SHOULD_PROVIDE_NEW_TAMP_PUB_KEY = 14,
    REQUEST_ERROR_SHOULD_PROCESS_OFFCHAIN_REQUEST = 15,
    REQUEST_ERROR_NO_OFFCHAIN_LIQUIDITY = 16,

    REQUEST_ERROR_ADDRESS_SHOULD_BE_GENERATED = 20,

    REQUEST_ERROR_EXPIRED_ACCESS_TOKEN = 30,
    REQUEST_ERROR_BAD_ACCESS_TOKEN = 31,
    REQUEST_ERROR_NO_ENCODED_MAIN_KEY = 32,
    REQUEST_ERROR_PREVIOUS_TRANSACTION_WERE_NOT_COMPLETED =33,
    REQUEST_ERROR_LIMITATION_CHECK_FAILED = 34,

    REQUEST_ERROR_BAD_REQUEST = 999
} REQUEST_ERROR_TYPE;

typedef enum : NSUInteger {
  REQUEST_HTTP_CODE_SUCCESS = 200,
  REQUEST_HTTP_CODE_REDIRECTION = 300,
  
} REQUEST_HTTP_CODE;

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
