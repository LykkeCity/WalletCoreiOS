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
#import <CoreBitcoin/BTCKey.h>
#import <CoreBitcoin/BTCAddress.h>
#import "LWUtils.h"
#import "LWCache.h"
#import "LWAssetPairModel.h"
#import "LWKeychainManager.h"
#import "LWPrivateWalletModel.h"
#import "LWAssetModel.h"
#import "LWMarginalAccount.h"

@implementation LWOffchainTransactionsManager

-(id) init {
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


-(void) sendSwapRequestForAsset:(NSString *) baseAsset pair:(NSString *) assetPairId volume:(double) volume completion:(void (^)(NSDictionary *))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
    LWAssetPairModel *assetPair;
    for(LWAssetPairModel *p in [LWCache instance].allAssetPairs) {
        if([p.identity isEqualToString:assetPairId]) {
            assetPair = p;
            break;
        }
    }
    
    NSString *channelAsset;
    
    if(volume > 0) {
        if([assetPair.baseAssetId isEqualToString:baseAsset]) {
            channelAsset = assetPair.quotingAssetId;
        }
        else {
            channelAsset = assetPair.baseAssetId;
        }
    }
    else {
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
                             @"Volume": @(volume),
                             @"PrevTempPrivateKey":prevKeyWif
                             };
    NSLog(@"%@", params);
        
    NSMutableURLRequest *request = [self createRequestWithAPI:@"offchain/trade" httpMethod:@"POST" getParameters:nil postParameters:params];
        
        [self makeOperationWithRequest:request details:details];
    });
    
}


- (void) requestCashOut:(NSNumber *)amount assetId:(NSString *)assetId multiSig:(NSString *)multiSig completion:(void (^)(NSDictionary *))completion {
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
        NSLog(@"%@", params);
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

- (void) requestCashOutSwiftWithParams:(NSDictionary *)params completion:(void (^)(NSDictionary *))completion {
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
        NSLog(@"%@", newParams);
        NSMutableURLRequest *request = [self createRequestWithAPI:@"offchain/cashout/swift" httpMethod:@"POST" getParameters:nil postParameters:newParams];
        [self makeOperationWithRequest:request details:details];
    });
}


-(void) requestTransferToMarginAccount:(LWMarginalAccount *)account amount:(NSNumber *) amount completion:(void (^)(NSDictionary *))completion {
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
        
        NSLog(@"%@", params);
        NSMutableURLRequest *request = [self createRequestWithAPI:@"offchain/trasferToMargin" httpMethod:@"POST" getParameters:nil postParameters:params];
        [self makeOperationWithRequest:request details:details];
    });
}




-(void) makeOperationWithRequest: (NSURLRequest *) request details:(NSDictionary *) details {
    
    id result = [self sendRequest:request];
    if([result isKindOfClass:[NSDictionary class]]) {
        NSString *transaction = result[@"TransactionHex"];
        int operationResult = [result[@"OperationResult"] intValue];
        NSString *transferId = result[@"TransferId"];
        
        if(operationResult == 1) {
            [self processChannel:transaction transferId:transferId details:details];
        }
        else if(operationResult ==0) {
            [self finalizeTransfer:transaction transferId:transferId details:details];
        }
        
    }
    else {
        if([result isKindOfClass:[NSError class]] && [(NSError *)result code] == 15) {
            [self getRequestsInBackground:NO];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self makeOperationWithRequest:request details:details];

                });
            });
        }
        else {
            NSDictionary *completionResult;
            if([result isKindOfClass:[NSError class]]) {
                NSError* completionError = result;
                completionResult = @{
                                     @"Error": @{
                                             @"Message": completionError.userInfo[@"Message"]
                                   }
                };
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                void (^completion)(NSDictionary *) = details[@"Completion"];
                if(completion != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(completionResult);
                    });
                }
            });
        }
    }

    
    
}


-(void) processChannel:(NSString *) transaction transferId:(NSString *) transferId details:(NSDictionary *) details {
    NSString *signedTransaction;
    if(!details[@"FromWallet"]) {
        signedTransaction = [LWTransactionManager signOffchainTransaction:transaction withKey:[LWPrivateKeyManager shared].wifPrivateKeyLykke type:OffchainTransactionTypeCreateChannel];
    }
    else {
        LWPrivateWalletModel *wallet = details[@"FromWallet"];
        signedTransaction = [LWTransactionManager signOffchainTransaction:transaction withKey:wallet.privateKey type:OffchainTransactionTypeCashIn];
        NSMutableDictionary *newDetails = [details mutableCopy];
        [newDetails removeObjectForKey:@"FromWallet"];
        details = newDetails;
    }
    
    NSMutableURLRequest *request1 = [self createRequestWithAPI:@"offchain/processchannel" httpMethod:@"POST" getParameters:nil postParameters:@{@"TransferId":transferId,
                                                                                                                                                @"SignedChannelTransaction":signedTransaction
                                                                                                                                                }];
    
    id result = [self sendRequest:request1];
    if([result isKindOfClass:[NSDictionary class]]) {
        NSString *transaction = result[@"TransactionHex"];
        int operationResult = [result[@"OperationResult"] intValue];
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


-(void) finalizeTransfer:(NSString *) transaction transferId:(NSString *) transferId details:(NSDictionary *) details {
    
    BTCKey *key = [[LWPrivateKeyManager shared] generateKey];
    NSString *pubKey = [LWUtils hexStringFromData:key.publicKey];
    NSString *wif;
   
    if([LWPrivateKeyManager shared].isDevServer) {
        wif = key.WIFTestnet;
    }
    else {
        wif = key.WIF;
    }

    NSString *signedTransaction;
    if(!details[@"FromWallet"]) {
        signedTransaction = [LWTransactionManager signOffchainTransaction:transaction withKey:[LWPrivateKeyManager shared].wifPrivateKeyLykke type:OffchainTransactionTypeTransfer];
    }
    else {
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
            NSString *transaction = result[@"TransactionHex"];
            int operationResult = [result[@"OperationResult"] intValue];
            NSString *transferId = result[@"TransferId"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[LWKeychainManager instance] saveOffchainLastPrivateKey:wif forAssetId:details[@"ChannelAsset"]];
                if(completion != nil) {
                    if(result[@"Order"]) {
                        completion(result[@"Order"]);
                    }
                    else {
                        completion(@{});
                    }
                }

            });
        }
        else {
            if(completion != nil) {
                completion(nil);
            }

        }
    
}

-(void) getRequests {
    
    [self getRequestsInBackground:YES];
}

-(void) getRequestsInBackground:(BOOL) flagBack {
    if([LWKeychainManager instance].isAuthenticated == NO) {
        return;
    }
    NSMutableURLRequest *request = [self createRequestWithAPI:@"offchain/requests" httpMethod:@"GET" getParameters:nil postParameters:nil];
    
    
    void (^block)(void) = ^{
        id result = [self sendRequest:request];
        
        
        if([result isKindOfClass:[NSDictionary class]]) {
            for(NSDictionary *d in result[@"Requests"]) {
                if([self processRequest:d] == NO) {
                    break;
                }
            }
        }
        if(flagBack == YES) {  // We probably got notification with completion handler
            dispatch_async(dispatch_get_main_queue(), ^{
                [[LWTransactionManager shared] endAction];
            });
        }
    };
    if(flagBack) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       block
                       );
    }
    else {
        block();
    }
}


-(BOOL) processRequest:(NSDictionary *) requestDict {
    NSString *requestId = requestDict[@"RequestId"];
    int operationResult = [requestDict[@"Type"] intValue];
    NSString *channelAsset = requestDict[@"Asset"];
    
    if(operationResult == 1) {
        
        NSString *prevKeyWif = [self getPreviousPrivateKeyForChannelAsset:channelAsset];

        if(!prevKeyWif)
            prevKeyWif = [[LWKeychainManager instance] offchainLastPrivateKeyForAsset:channelAsset];
        
        NSMutableURLRequest *request1 = [self createRequestWithAPI:@"offchain/requestTransfer" httpMethod:@"POST" getParameters:nil postParameters:@{
                                                                                                                                                     @"RequestId": requestId,
                                                                                                                                                     @"PrevTempPrivateKey": prevKeyWif,
                                                                                                                                                     
                                                                                                                                                     }];
        id result = [self sendRequest:request1];
        
        if([result isKindOfClass:[NSDictionary class]]) {
            NSString *transaction = result[@"TransactionHex"];
            int operationResult = [result[@"OperationResult"] intValue];
            NSString *transferId = result[@"TransferId"];
            
            if(operationResult == 1) {
                [self processChannel:transaction transferId:transferId details:@{@"ChannelAsset": channelAsset}];
            }
            else if(operationResult ==0) {
                [self finalizeTransfer:transaction transferId:transferId details:@{@"ChannelAsset": channelAsset}];
            }
            
        }
        else if([result isKindOfClass:[NSError class]] && [(NSError *)result code] == 12) {
            return NO;
        }


        
    }
    return YES;
}



-(NSString *) getPreviousPrivateKeyForChannelAsset:(NSString *) assetId {
    
    NSMutableURLRequest *request = [self createRequestWithAPI:@"offchain/channelkey" httpMethod:@"GET" getParameters:@{@"asset":assetId} postParameters:nil];
    
    id result = [self sendRequest:request];
    
    if([result isKindOfClass:[NSDictionary class]] && result[@"Key"]) {
        return [[LWPrivateKeyManager shared] decryptExternalWalletKey:result[@"Key"]];
    }

    
    return nil;
}


@end
