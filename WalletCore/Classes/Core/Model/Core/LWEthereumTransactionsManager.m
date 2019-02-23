//
//  LWEthereumTransactionsManager.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 29/05/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWEthereumTransactionsManager.h"
#import "LWAssetModel.h"
#import "LWAssetPairModel.h"
#import "LWEthereumSignManager.h"
#import "LWUtils.h"
#import "LWCache.h"
#import "LWPrivateKeyManager.h"
#import <CoreBitcoin/BTCKey.h>
#import "LWAuthManager.h"

@interface LWEthereumTransactionsManager() {
    LWEthereumSignManager *signManager;
    
}

@end

@implementation LWEthereumTransactionsManager

+ (instancetype)shared
{
    static LWEthereumTransactionsManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[LWEthereumTransactionsManager alloc] init];
    });
    return shared;
}

- (void)requestSellLimitOrderForBaseAsset:(LWAssetModel *)asset
									 pair:(LWAssetPairModel *)pair
								   volume:(NSString *)volume
									price:(NSString *)price
							   completion:(void (^)(NSDictionary *))completion {
	[self requestTradeForBaseAsset:asset
							  pair:pair
						   isLimit:YES
						 addressTo:nil
							volume:(NSNumber *)volume
							 price:price
						completion:completion];
}

- (void)requestTradeForBaseAsset:(LWAssetModel *)asset
							pair:(LWAssetPairModel *)pair
					   addressTo:(NSString *)addressTo
						  volume:(NSNumber *)volume
					  completion:(void (^)(NSDictionary *))completion {
	[self requestTradeForBaseAsset:asset
							  pair:pair
						   isLimit:NO
						 addressTo:addressTo
							volume:volume
							 price:nil
						completion:completion];
}

- (void)requestTradeForBaseAsset:(LWAssetModel *)asset
							pair:(LWAssetPairModel *)pair
						 isLimit:(BOOL)isLimit
					   addressTo:(NSString *)addressTo
						  volume:(NSNumber *)volume
						   price:(NSString *)price
					  completion:(void (^)(NSDictionary *))completion {
    
    [self createEthereumSignManagerForAsset:asset completion:^(BOOL flag) {
        if (flag) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
                NSMutableDictionary *params = @{ @"Asset": asset.identity,
												 @"Volume": volume,
												 @"IsLimit": @(isLimit)}.mutableCopy;
				if (price) {
					params[@"Price"] = price;
				}
				if (addressTo) {
					params[@"AddressTo"] = addressTo;
				}
				if (pair) {
					params[@"AssetPair"] = pair.identity;
				}
				
                NSURLRequest *request = [self createRequestWithAPI:@"ethereum/hash" httpMethod:@"POST" getParameters:nil postParameters: params];
                NSDictionary *result = [self sendRequest:request];
                if([result isKindOfClass:[NSDictionary class]] == NO) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil);
                    });
                    return;
                }
                NSString *identity = result[@"Id"];
                NSString *hash = result[@"Hash"];
                
            __block NSString *signedHash;
            dispatch_sync(dispatch_get_main_queue(), ^{
                signedHash = [signManager signHash:hash];
            });
                
                NSString *transferParameter = pair ? @"TransferWithMargin" : @"Transfer";
                NSMutableDictionary *paramsTrade = [@{
                                                       @"Asset": asset.identity,
                                                       @"Volume": volume,
                                                       transferParameter: @{@"Id":identity,
                                                                                @"Sign": signedHash
                                                                                }
                                                       } mutableCopy];
                if(pair) {
                    paramsTrade[@"AssetPair"] = pair.identity;
                    request = [self createRequestWithAPI:@"ethereum/trade" httpMethod:@"POST" getParameters:nil postParameters: paramsTrade];

                }
                else {
                    request = [self createRequestWithAPI:@"ethereum/cashout" httpMethod:@"POST" getParameters:nil postParameters: paramsTrade];
                }
                
            
                result = [self sendRequest:request];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(completion != nil) {
                        if([result isKindOfClass:[NSDictionary class]] && result[@"Order"]) {
                            completion(result[@"Order"]);
                        }
                        else {
                            completion(result);
                        }
                    }

                    });
            
            });
        }
        else {
            completion(nil);
            return;
        }
    
    }];
    
    
    
//    void (^addressCreateBlock)(void) = ^{
//        
//    
//    };
    
}

-(void) requestCashoutForAsset:(LWAssetModel *)asset volume:(NSNumber *)volume addressTo:(NSString *) addressTo completion:(void (^)(NSDictionary *))completion {
    [self requestTradeForBaseAsset:asset pair:nil addressTo:addressTo volume:volume completion:^(NSDictionary *result){
        completion(result);
    }];
}

- (void)createEthereumSignManagerForAsset:(LWAssetModel *)asset completion:(void (^)(BOOL))completion {
    if(signManager && asset.blockchainDepositAddress.length > 0) {
        completion(YES);
        return;
    }
	
    if(asset.blockchainDepositAddress.length > 0) {
        signManager = [[LWEthereumSignManager alloc] initWithEthPrivateKey:[LWUtils hexStringFromData:[LWPrivateKeyManager shared].privateKeyLykke.privateKey] withCompletion:^{
            completion(YES);
        }];
        return;
    }
    
    NSData *data = [LWPrivateKeyManager shared].privateKeyLykke.privateKey;
    signManager = [[LWEthereumSignManager alloc] initWithEthPrivateKey:[LWUtils hexStringFromData:data] withCompletion:^{
        NSDictionary *dict = [signManager createAddressAndPubKey];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *address = dict[@"Address"];
            NSString *pubKey = dict[@"PubKey"];
            NSDictionary *params = @{@"AssetId":asset.identity,
                                     @"BcnWallet":@{@"Address": address,
                                                    @"PublicKey": pubKey}};
            NSURLRequest *request = [self createRequestWithAPI:@"Wallets" httpMethod:@"POST" getParameters:nil postParameters:params];
            NSDictionary *result = [self sendRequest:request];
            dispatch_async(dispatch_get_main_queue(), ^{
                if([result isKindOfClass:[NSDictionary class]]) {
                    asset.blockchainDepositAddress = result[@"Address"];
                  [[LWAuthManager instance] requestAllAssetsWithCompletion:^{
                    completion(YES);
                  }];
                } else{
                    completion(NO);
                }
             });
        });
    }];
}

- (void)requestEthereumOperationWithId:(NSString *)operationId assetId:(NSString *)assetId completion:(void(^)(BOOL))completion {
	LWAssetModel *asset = [LWCache assetById:assetId];
	[self createEthereumSignManagerForAsset:asset completion:^(BOOL flag) {
		if (!flag) {
			completion(NO);
			return;
		}
		
		NSString *url = [NSString stringWithFormat:@"ethereum/%@/hash", operationId];
		NSURLRequest *request = [self createRequestWithAPI:url httpMethod:kMethodPOST getParameters:nil postParameters:nil];
		
		[self sendRequest:request completion:^(NSDictionary *response) {
			if (![response isKindOfClass:[NSDictionary class]]) {
				completion(NO);
				return;
			}
			
			NSString *hash = response[@"Hash"];
			NSString *signedHash = [signManager signHash:hash];
			
			if (!signedHash) {
				completion(NO);
				return;
			}
			
			NSString *url = [NSString stringWithFormat:@"ethereum/%@/transfer", operationId];
			NSDictionary *params = @{ @"Sign": signedHash };
			NSURLRequest *request = [self createRequestWithAPI:url httpMethod:kMethodPOST getParameters:nil postParameters:params];
			[self sendRequest:request completion:^(NSDictionary *response) {
				BOOL success = [response isKindOfClass:[NSDictionary class]] && response[@"Order"];
				completion(success);
			}];
		}];
	}];
}

- (BOOL)showKycErrors {
    return NO;
}

-(void) logout {
    signManager = nil;
}

@end
