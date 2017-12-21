//
//  LWOffchainTransactionsManager.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 07/04/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWOffchainTransactionsManager.h"
#import "LWTransactionManager.h"
#import "LWPrivateKeyManager.h"
#import <CoreBitcoin/BTCAddress.h>
#import <CoreBitcoin/BTCKey.h>
#import "LWUtils.h"
#import "LWCache.h"
#import "LWAssetPairModel.h"
#import "LWKeychainManager.h"
#import "LWPrivateWalletModel.h"
#import "LWAssetModel.h"
#import "LWMarginalAccount.h"
#import "LWSwiftCashOutDetailsModel.h"
#import <WalletCore/WalletCore-Swift.h>

// TODO: replace details = @{ @"AssetId": ..., @"Completion": ... } with LWOffchainCompletion
@interface LWOffchainCompletion: NSObject

@property (strong, nonatomic) NSString *assetId;
@property (copy, nonatomic) void(^completion)(NSDictionary *);

+ (instancetype)objectWithAssetId:(NSString *)assetId completion:(void(^)(NSDictionary *))completion;

@end

@implementation LWOffchainCompletion

+ (instancetype)objectWithAssetId:(NSString *)assetId completion:(void(^)(NSDictionary *))completion {
	LWOffchainCompletion *object = [LWOffchainCompletion new];
	object.assetId = assetId;
	object.completion = completion;
	return object;
}

@end

@implementation LWOffchainTransactionsManager

- (id)init {
  self = [super init];
  
  return self;
}

+ (instancetype)shared
{
  static LWOffchainTransactionsManager *shared = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [[LWOffchainTransactionsManager alloc] init];
  });
  return shared;
}


- (void)sendSwapRequestForAsset:(NSString *)baseAsset pair:(NSString *)assetPairId volume:(NSNumber *)volume completion:(void (^)(NSDictionary *))completion {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    LWAssetPairModel *assetPair;
    for(LWAssetPairModel *p in [LWCache instance].allAssetPairs) {
      if([p.identity isEqualToString:assetPairId]) {
        assetPair = p;
        break;
      }
    }
    
    NSString *channelAsset;
    
    if (volume.doubleValue > 0) {
      if([assetPair.baseAssetId isEqualToString:baseAsset]) {
        channelAsset = assetPair.quotingAssetId;
      } else {
        channelAsset = assetPair.baseAssetId;
      }
    } else {
      channelAsset = baseAsset;
    }
    
    NSString *prevKeyWif = [self getPreviousPrivateKeyForChannelAsset:channelAsset];
    if(!prevKeyWif)
      prevKeyWif = [[LWKeychainManager instance] offchainLastPrivateKeyForAsset:channelAsset];
    
    NSDictionary *details = @{
                              @"ChannelAsset": channelAsset,
                              @"Completion": completion,
                              };
    
    NSDictionary *params = @{
                             @"AssetPair":assetPairId,
                             @"Asset": baseAsset,
                             @"Volume": volume,
                             @"PrevTempPrivateKey":prevKeyWif
                             };
    
    NSMutableURLRequest *request = [self createRequestWithAPI:@"offchain/trade" httpMethod:@"POST" getParameters:nil postParameters:params];
    
    [self makeOperationWithRequest:request details:details];
  });
  
}

- (void)requestCashOut:(NSDecimalNumber *)amount assetId:(NSString *)assetId multiSig:(NSString *)multiSig completion:(void (^)(NSDictionary *))completion {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    NSString *channelAsset = assetId;
    
    NSDictionary *details = @{
                              @"ChannelAsset": channelAsset,
                              @"Completion": completion,
                              };
    
    NSString *prevKeyWif = [self getPreviousPrivateKeyForChannelAsset:channelAsset];
    if(!prevKeyWif)
      prevKeyWif = [[LWKeychainManager instance] offchainLastPrivateKeyForAsset:channelAsset];
    
    
    NSMutableDictionary *params = [@{
                                     @"Asset": assetId,
                                     @"Amount": amount,
                                     @"PrevTempPrivateKey":prevKeyWif
                                     } mutableCopy];
    NSMutableURLRequest *request;// = [self createRequestWithAPI:@"offchain/cashout" httpMethod:@"POST" getParameters:nil postParameters:params];
    if(multiSig.length) {
      params[@"Destination"] = multiSig;
      request = [self createRequestWithAPI:@"offchain/cashout" httpMethod:@"POST" getParameters:nil postParameters:params];
    }
    else {
      request = [self createRequestWithAPI:@"offchain/cashout/forward" httpMethod:@"POST" getParameters:nil postParameters:params]; //forward settlement
    }
    
    [self makeOperationWithRequest:request details:details];
  });
}

- (void)requestCashOutSwiftWithParams:(NSDictionary *)params completion:(void (^)(NSDictionary *))completion {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    NSString *channelAsset = params[@"Asset"];
    
    NSDictionary *details = @{
                              @"ChannelAsset": channelAsset,
                              @"Completion": completion,
                              };
    
    NSString *prevKeyWif = [self getPreviousPrivateKeyForChannelAsset:channelAsset];
    if(!prevKeyWif)
      prevKeyWif = [[LWKeychainManager instance] offchainLastPrivateKeyForAsset:channelAsset];
    
    NSMutableDictionary *newParams = [params mutableCopy];
    newParams[@"PrevTempPrivateKey"] = prevKeyWif;
    NSMutableURLRequest *request = [self createRequestWithAPI:@"offchain/cashout/swift" httpMethod:@"POST" getParameters:nil postParameters:newParams];
    [self makeOperationWithRequest:request details:details];
  });
}

- (void)requestTransferToMarginAccount:(LWMarginalAccount *)account amount:(NSNumber *)amount completion:(void (^)(NSDictionary *))completion {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    NSString *channelAsset = account.baseAssetId;
    
    NSDictionary *details = @{
                              @"ChannelAsset": channelAsset,
                              @"Completion": completion,
                              };
    
    NSString *prevKeyWif = [self getPreviousPrivateKeyForChannelAsset:channelAsset];
    if(!prevKeyWif)
      prevKeyWif = [[LWKeychainManager instance] offchainLastPrivateKeyForAsset:channelAsset];
    
    NSDictionary *params = @{@"PrevTempPrivateKey": prevKeyWif, @"AccountId":account.identity, @"Amount":amount};
    
    NSMutableURLRequest *request = [self createRequestWithAPI:@"offchain/transferToMargin" httpMethod:@"POST" getParameters:nil postParameters:params];
    [self makeOperationWithRequest:request details:details];
  });
}

- (void)makeOperationWithRequest:(NSURLRequest *)request details:(NSDictionary *)details {
  
  id result = [self sendRequest:request];
  if([result isKindOfClass:[NSDictionary class]]) {
    NSString *transaction = result[@"TransactionHex"];
    int operationResult = [result[@"OperationResult"] intValue];
    NSString *transferId = result[@"TransferId"];
    
    if(operationResult == 1) {
      [self processChannel:transaction transferId:transferId details:details];
    } else if(operationResult ==0) {
      [self finalizeTransfer:transaction transferId:transferId details:details];
    }
    
  } else {
    if([result isKindOfClass:[NSError class]] && [(NSError *)result code] == 15) {
      [self getRequestsInBackground:NO];
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          [self makeOperationWithRequest:request details:details];
          
        });
      });
    } else {
      dispatch_async(dispatch_get_main_queue(), ^{
        void (^completion)(NSDictionary *) = details[@"Completion"];
        if(completion != nil) {
          dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil);
          });
        }
      });
    }
  }
}


- (void)processChannel:(NSString *)transaction transferId:(NSString *)transferId details:(NSDictionary *)details {
  NSString *signedTransaction;
  if(!details[@"FromWallet"]) {
    signedTransaction = [LWTransactionManager signOffchainTransaction:transaction withKey:[LWPrivateKeyManager shared].wifPrivateKeyLykke type:OffchainTransactionTypeCreateChannel];
  } else {
    LWPrivateWalletModel *wallet = details[@"FromWallet"];
    signedTransaction = [LWTransactionManager signOffchainTransaction:transaction withKey:wallet.privateKey type:OffchainTransactionTypeCashIn];
    NSMutableDictionary *newDetails = [details mutableCopy];
    [newDetails removeObjectForKey:@"FromWallet"];
    details = newDetails;
  }
  if(!transferId || !signedTransaction) {
    void (^completion)(NSDictionary *) = details[@"Completion"];
    if(completion != nil) {
      dispatch_async(dispatch_get_main_queue(), ^{
        completion(nil);
      });
    }
    return;
  }
  NSMutableURLRequest *request1 = [self createRequestWithAPI:@"offchain/processchannel" httpMethod:@"POST" getParameters:nil postParameters:@{@"TransferId":transferId,
                                                                                                                                              @"SignedChannelTransaction":signedTransaction
                                                                                                                                              }];
  
  id result = [self sendRequest:request1];
  if([result isKindOfClass:[NSDictionary class]]) {
    NSString *transaction = result[@"TransactionHex"];
    NSString *transferId = result[@"TransferId"];
    [self finalizeTransfer:transaction transferId:transferId details:details];
  }
  else {
    void (^completion)(NSDictionary *) = details[@"Completion"];
    if(completion != nil) {
      dispatch_async(dispatch_get_main_queue(), ^{
        completion(nil);
      });
    }
    
  }
}


- (void)finalizeTransfer:(NSString *)transaction transferId:(NSString *)transferId details:(NSDictionary *)origDetails {
  
  BTCKey *key = [[LWPrivateKeyManager shared] generateKey];
  NSString *pubKey = [LWUtils hexStringFromData:key.publicKey];
  NSString *wif;
  
  if([LWPrivateKeyManager shared].isDevServer) {
    wif = key.WIFTestnet;
  } else {
    wif = key.WIF;
  }
  
  NSString *signedTransaction;
  NSDictionary *details = origDetails;
  if (!details[@"FromWallet"]) {
    signedTransaction = [LWTransactionManager signOffchainTransaction:transaction withKey:[LWPrivateKeyManager shared].wifPrivateKeyLykke type:OffchainTransactionTypeTransfer];
  } else {
    LWPrivateWalletModel *wallet = details[@"FromWallet"];
    signedTransaction = [LWTransactionManager signOffchainTransaction:transaction withKey:wallet.privateKey type:OffchainTransactionTypeCashIn];
    NSMutableDictionary *newDetails = [details mutableCopy];
    [newDetails removeObjectForKey:@"FromWallet"];
    details = newDetails;
  }
  
  NSMutableURLRequest *request = [self createRequestWithAPI:@"offchain/finalizetransfer" httpMethod:@"POST" getParameters:nil postParameters:@{@"TransferId":transferId,
                                                                                                                                               @"SignedTransferTransaction":signedTransaction,
                                                                                                                                               @"ClientRevokePubKey":pubKey,
                                                                                                                                               @"ClientRevokeEncryptedPrivateKey":[[LWPrivateKeyManager shared] encryptExternalWalletKey:wif]
                                                                                                                                               }];
  
  id result = [self sendRequest:request];
  
  void (^completion)(NSDictionary *) = details[@"Completion"];
  
  if([result isKindOfClass:[NSDictionary class]]) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [[LWKeychainManager instance] saveOffchainLastPrivateKey:wif forAssetId:details[@"ChannelAsset"]];
      if(completion != nil) {
        if(result[@"Order"]) {
          completion(result[@"Order"]);
        } else {
          completion(@{});
        }
      }
    });
  } else if(completion != nil) {
    completion(nil);
  }
}

- (void)getRequests {
  
  [self getRequestsInBackground:YES];
}

- (NSArray *)getRequestsInBackground:(BOOL)flagBack {  //Return the list of failed assets
  if([LWKeychainManager instance].isAuthenticated == NO) {
    return nil;
  }
  NSMutableURLRequest *request = [self createRequestWithAPI:@"offchain/requests" httpMethod:@"GET" getParameters:nil postParameters:nil];
  
  __block NSMutableArray *failedList = [[NSMutableArray alloc] init];
  
  void (^block)(void) = ^{
    id result = [self sendRequest:request];
    
    if ([result isKindOfClass:[NSDictionary class]]) {
      for(NSDictionary *d in result[@"Requests"]) {
        if([failedList containsObject:d[@"Asset"]]) {
          continue;
        }
        if([self processRequest:d] == NO) {
          [failedList addObject:@"Asset"];
        }
      }
    }
    if (flagBack == YES) {  // We probably got notification with completion handler
      dispatch_async(dispatch_get_main_queue(), ^{
        [[LWTransactionManager shared] endAction];
      });
    }
  };
  if (flagBack) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   block
                   );
  } else {
    block();
  }
  return failedList;
}


- (BOOL)processRequest:(NSDictionary *)requestDict {
  NSString *requestId = requestDict[@"RequestId"];
  int operationResult = [requestDict[@"Type"] intValue];
  NSString *channelAsset = requestDict[@"Asset"];
  
  if(operationResult == 1) {
    
    NSString *prevKeyWif = [self getPreviousPrivateKeyForChannelAsset:channelAsset];
    
    if(!prevKeyWif) {
      prevKeyWif = [[LWKeychainManager instance] offchainLastPrivateKeyForAsset:channelAsset];
    }
    
    NSMutableURLRequest *request1 = [self createRequestWithAPI:@"offchain/requestTransfer"
                                                    httpMethod:@"POST"
                                                 getParameters:nil
                                                postParameters:@{@"RequestId": requestId,
                                                                 @"PrevTempPrivateKey": prevKeyWif}];
    id result = [self sendRequest:request1];
    
    if([result isKindOfClass:[NSDictionary class]]) {
      NSString *transaction = result[@"TransactionHex"];
      int operationResult = [result[@"OperationResult"] intValue];
      NSString *transferId = result[@"TransferId"];
      
      if(operationResult == 1) {
        [self processChannel:transaction transferId:transferId details:@{@"ChannelAsset": channelAsset}];
      } else if(operationResult ==0) {
        [self finalizeTransfer:transaction transferId:transferId details:@{@"ChannelAsset": channelAsset}];
      }
    } else if([result isKindOfClass:[NSError class]]) {
      return NO;
    }
  }
  return YES;
}

- (NSString *)getPreviousPrivateKeyForChannelAsset:(NSString *) assetId {
  
  NSMutableURLRequest *request = [self createRequestWithAPI:@"offchain/channelkey" httpMethod:@"GET" getParameters:@{@"asset":assetId} postParameters:nil];
  
  id result = [self sendRequest:request];
  
  if([result isKindOfClass:[NSDictionary class]] && result[@"Key"]) {
    return [[LWPrivateKeyManager shared] decryptExternalWalletKey:result[@"Key"]];
  }
  
  return nil;
}

- (void)getPreviousPrivateKeyForChannelAsset:(NSString *)assetId completion:(void(^)(NSString *))completion {
	NSDictionary *params = @{ @"asset": assetId };
	NSMutableURLRequest *request = [self createRequestWithAPI:@"offchain/channelkey" httpMethod:kMethodGET getParameters:params postParameters:nil];
	[self sendRequest:request completion:^(NSDictionary *response) {
		NSString *key = nil;
		if ([response isKindOfClass:[NSDictionary class]] && response[@"Key"]) {
			key = [[LWPrivateKeyManager shared] decryptExternalWalletKey:response[@"Key"]];
		}
		completion(key);
	}];
}

- (void)getSwiftCashOutDetails:(void (^)(LWSwiftCashOutDetailsModel *, NSError *))completion {
  NSURLRequest *request = [self createRequestWithAPI:@"offchain/cashout/swift" httpMethod:@"GET" getParameters:nil postParameters:nil];
  
  [self sendRequest:request completion:^(NSDictionary *response) {
    if ([response isKindOfClass:[NSError class]]) {
      completion(nil, (NSError *)response);
    } else {
      LWSwiftCashOutDetailsModel *model = nil;
      if (response) {
        model = [[LWSwiftCashOutDetailsModel alloc] initWithJSON:response];
      }
      completion(model, nil);
    }
  }];
}

- (void)requestTrustedOperationWithId:(NSString *)operationId completion:(void(^)(BOOL success))completion {
	NSString *url = [NSString stringWithFormat:@"operations/%@", operationId];
	NSURLRequest *request = [self createRequestWithAPI:url httpMethod:kMethodGET getParameters:nil postParameters:nil];
	
	[self sendRequest:request completion:^(NSDictionary *response) {
		if ([response isKindOfClass:[NSError class]]) {
			completion(NO);
			return;
		}
		
		LWOperationModel *operation = [EKMapper objectFromExternalRepresentation:response withMapping:[LWOperationModel objectMapping]];
		
		if (operation.type != LWOperationTypeTransfer) {
			completion(NO);
			return;
		}
		
		LWOperationTransferModel *transfer = operation.transfer;
		if (transfer.transferType == LWOperationTransferTypeTradingToTrusted) {
			LWAssetModel *asset = [LWCache assetById:transfer.assetId];
			if (asset.blockchainType == LWBlockchainTypeBitcoint) {
				NSString *url = [NSString stringWithFormat:@"offchain/%@/transferToTrusted", operationId];
				[self requestTransferForOperationWithUrl:url assetId:transfer.assetId completion:completion];
			} else if (asset.blockchainType == LWBlockchainTypeEthereum) {
				[[LWEthereumTransactionsManager shared] requestEthereumOperationWithId:operationId assetId:transfer.assetId completion:completion];
			} else {
				completion(NO);
			}
		} else {
			NSString *url = [NSString stringWithFormat:@"trustedWallets/%@/transfer", operationId];
			NSURLRequest *request = [self createRequestWithAPI:url httpMethod:kMethodPOST getParameters:nil postParameters:nil];
			[self sendRequest:request completion:^(NSDictionary *response) {
				completion(YES);
			}];
		}
	}];
}

- (void)requestTransferForOperationWithUrl:(NSString *)url assetId:(NSString *)assetId completion:(void(^)(BOOL success))completion {
	[self getPreviousPrivateKeyForChannelAsset:assetId completion:^(NSString *key) {
		if (!key) {
			completion(NO);
			return;
		}
		
		void(^operationCompletion)(NSDictionary *) = ^(NSDictionary *response) {
			completion(response != nil);
		};
		
		NSDictionary *details = @{ @"ChannelAsset": assetId,
								   @"Completion": operationCompletion };
		NSDictionary *params = @{ @"PrevTempPrivateKey": key };
		NSURLRequest *request = [self createRequestWithAPI:url httpMethod:kMethodPOST getParameters:nil postParameters:params];
		[self makeOperationWithRequest:request details:details];
	}];
}

- (void)requestCancelTrustedOperationWithCompletion:(void(^)(BOOL success))completion {
	NSURLRequest *request = [self createRequestWithAPI:@"operations/cancel" httpMethod:kMethodPOST getParameters:nil postParameters:nil];
	
	[self sendRequest:request completion:^(NSDictionary *response) {
		if (completion) {
			completion(YES);
		}
	}];
}

- (BOOL)showKycErrors {
  return NO;
}

@end
