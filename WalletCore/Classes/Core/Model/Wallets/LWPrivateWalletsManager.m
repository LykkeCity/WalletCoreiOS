//
//  LWPrivateWalletsManager.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 22/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateWalletsManager.h"
#import "LWKeychainManager.h"
#import "LWPrivateWalletModel.h"
#import "LWPrivateKeyManager.h"
#import "LWPrivateWalletAssetModel.h"
#import "LWPrivateWalletHistoryCellModel.h"
#import "LWCache.h"
#import "LWPKBackupModel.h"
#import "LWPKTransferModel.h"

@implementation LWPrivateWalletsManager

+ (instancetype)shared
{
    static LWPrivateWalletsManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[LWPrivateWalletsManager alloc] init];
    });
    return shared;
}

-(void) backupPrivateKeyWithModel:(LWPKBackupModel *) model  withCompletion:(void (^)(BOOL))completion
{
    NSMutableURLRequest *request=[self createRequestWithAPI:@"PrivateWalletBackup" httpMethod:@"POST" getParameters:nil postParameters:@{@"WalletAddress":model.address, @"WalletName":model.walletName, @"SecurityQuestion":model.hint, @"PrivateKeyBackup": model.encodedKey}];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *dict=[self sendRequest:request];
        
        NSLog(@"%@", dict);
        if(completion)
        {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
        }
        
    });

}

-(void) loadWalletsWithCompletion:(void (^)(NSArray *))completion
{
    NSMutableURLRequest *request=[self createRequestWithAPI:@"PrivateWallet" httpMethod:@"GET" getParameters:nil postParameters:nil];
    
    double CurrentTime0 = CACurrentMediaTime();

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        double CurrentTime = CACurrentMediaTime();
        
        NSDictionary *dict=[self sendRequest:request];
        
        double CurrentTime1 = CACurrentMediaTime();
        
//        NSLog(@"%@", dict);
        if(completion && [dict isKindOfClass:[NSDictionary class]] && dict[@"Wallets"])
        {
            NSMutableArray *array=[[NSMutableArray alloc] init];
            for(NSDictionary *d in dict[@"Wallets"])
            {
                LWPrivateWalletModel *wallet=[[LWPrivateWalletModel alloc] initWithDict:d];
                if(wallet)
                    [array addObject:wallet];
            }
            
            self.wallets=array;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                double CurrentTime2 = CACurrentMediaTime();
                
                double bbb=CurrentTime2-CurrentTime1;
                double eee=CurrentTime-CurrentTime0;
                completion(array);
//            double CurrentTime2 = CACurrentMediaTime();
                
                
                
            });
        }
    
    });
}



-(void) deleteWallet:(NSString *) address withCompletion:(void (^)(BOOL))completion
{
    NSMutableURLRequest *request=[self createRequestWithAPI:@"PrivateWallet" httpMethod:@"DELETE" getParameters:@{@"Address":address} postParameters:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *dict=[self sendRequest:request];
        
        NSLog(@"%@", dict);
        if(completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
            completion(YES);
            });
        }
        
    });

}


-(void) loadWalletBalances:(NSString *) address withCompletion:(void (^)(NSArray *))completion
{
    NSMutableURLRequest *request=[self createRequestWithAPI:@"PrivateWalletBalance" httpMethod:@"GET" getParameters:@{@"Address":address} postParameters:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *dict=[self sendRequest:request];
        
//        NSLog(@"%@", dict);
        if(completion && [dict isKindOfClass:[NSDictionary class]])
        {
            NSMutableArray *assets=[[NSMutableArray alloc] init];
            if([dict[@"Balances"] isKindOfClass:[NSArray class]])
            {
                for(NSDictionary *d in dict[@"Balances"])
                {
                    LWPrivateWalletAssetModel *model=[[LWPrivateWalletAssetModel alloc] initWithDict:d];
                    [assets addObject:model];
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^{
            completion(assets);
            });
        }
        
    });

}


-(void) addNewWallet:(LWPrivateWalletModel *) wallet   withCompletion:(void (^)(BOOL))completion
{
    NSMutableDictionary *params=[@{@"Address":wallet.address, @"Name":wallet.name, @"IsColdStorage":@(wallet.isColdStorageWallet)} mutableCopy];
    if(wallet.encryptedKey)
        params[@"EncodedPrivateKey"]=wallet.encryptedKey;
    NSMutableURLRequest *request=[self createRequestWithAPI:@"PrivateWallet" httpMethod:@"POST" getParameters:nil postParameters:params];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *dict=[self sendRequest:request];
        
        NSLog(@"%@", dict);
        if(completion)
        {
  
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
            completion([dict isKindOfClass:[NSError class]]==NO);
            });
        }
        
    });

}

-(void) updateWallet:(LWPrivateWalletModel *) wallet   withCompletion:(void (^)(BOOL))completion
{
    NSMutableURLRequest *request=[self createRequestWithAPI:@"PrivateWallet" httpMethod:@"PUT" getParameters:nil postParameters:@{@"Address":wallet.address, @"Name":wallet.name}];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *dict=[self sendRequest:request];
        
        NSLog(@"%@", dict);
        if(completion)
        {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
        }
        
    });
    
}


-(void) loadHistoryForWallet:(NSString *) address assetId:(NSString *) assetId withCompletion:(void(^)(NSArray *)) completion
{
    NSMutableURLRequest *request=[self createRequestWithAPI:@"PrivateWalletHistory" httpMethod:@"GET" getParameters:@{@"address":address} postParameters:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *result=[self sendRequest:request];
        
        NSLog(@"%@", result);
        if(completion)
        {
            if([result isKindOfClass:[NSArray class]]==NO)
            {
                completion(nil);
                return;
            }
            NSMutableArray *array=[[NSMutableArray alloc] init];
            
            
                for(NSDictionary *d in result)
                {
                    LWPrivateWalletHistoryCellModel *cell=[[LWPrivateWalletHistoryCellModel alloc] initWithDict:d];
                    [array addObject:cell];
                }
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(array);
            });
        }
        
    });

}

-(void) requestTransferTransaction:(LWPKTransferModel *) transfer withCompletion:(void(^)(NSDictionary *)) completion
{
    NSDictionary *params=@{@"SourceAddress":transfer.sourceWallet.address, @"DestinationAddress":transfer.destinationAddress, @"Amount":transfer.amount, @"AssetId":transfer.asset.assetId};
    NSMutableURLRequest *request=[self createRequestWithAPI:@"GenerateTransferTransaction" httpMethod:@"POST" getParameters:nil postParameters:params];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *dict=[self sendRequest:request];
        
        NSLog(@"%@", dict);
        if(completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(dict);
            });
        }
        
    });
}

-(void) broadcastTransaction:(NSString *) raw identity:(NSString *) identity withCompletion:(void(^)(BOOL)) completion
{
    NSDictionary *params=@{@"Id":identity, @"Hex":raw};
    NSMutableURLRequest *request=[self createRequestWithAPI:@"BroadcastTransaction" httpMethod:@"POST" getParameters:nil postParameters:params];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *dict=[self sendRequest:request];
        
        NSLog(@"%@", dict);
        if(completion)
        {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if([dict isKindOfClass:[NSError class]])
                    completion(NO);
                else
                    completion(YES);
            });
        }
        
    });
}

-(void) defrostColdStorageWallet:(LWPrivateWalletModel *)wallet withCompletion:(void (^)(BOOL))completion
{
    NSDictionary *params=@{@"Address":wallet.address, @"EncodedKey":wallet.encryptedKey};
    NSMutableURLRequest *request=[self createRequestWithAPI:@"privateWallet/key" httpMethod:@"POST" getParameters:nil postParameters:params];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *dict=[self sendRequest:request];
        
        NSLog(@"%@", dict);
        if(completion)
        {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if([dict isKindOfClass:[NSError class]])
                    completion(NO);
                else
                    completion(YES);
            });
        }
        
    });

}








@end
