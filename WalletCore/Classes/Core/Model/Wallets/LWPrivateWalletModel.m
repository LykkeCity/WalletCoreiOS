//
//  LWPrivateWalletModel.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateWalletModel.h"
#import "LWKeychainManager.h"
#import "LWPrivateWalletAssetModel.h"
#import "LWPrivateKeyManager.h"
#import "LWKeychainManager.h"

@implementation LWPrivateWalletModel

-(id) init
{
    self=[super init];
    _isExternalWallet=NO;
    _isColdStorageWallet=NO;
    return self;
}

-(id) initWithDict:(NSDictionary *) d
{
    self=[super init];
    
    if([d isKindOfClass:[NSDictionary class]]==NO || !d[@"Address"] || [d[@"Address"] isKindOfClass:[NSString class]]==NO)
        return nil;
    
    _isColdStorageWallet=NO;

    _isExternalWallet=NO;
    
    self.iconURL=d[@"MediumIconUrl"];
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    for(NSDictionary *b in d[@"Balances"])
    {
        LWPrivateWalletAssetModel *asset=[[LWPrivateWalletAssetModel alloc] initWithDict:b];
        [arr addObject:asset];
    }
    self.assets=arr;

    
    self.address=d[@"Address"];
    self.name=d[@"Name"];
    self.isColdStorageWallet=[d[@"IsColdStorage"] boolValue];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        double CurrentTime1 = CACurrentMediaTime();

        self.encryptedKey=d[@"EncodedPrivateKey"];
        if(!self.privateKey && self.encryptedKey)
        {
            self.privateKey=[[LWPrivateKeyManager shared] decryptExternalWalletKey:self.encryptedKey];
            _isExternalWallet=YES;
        }

    
//    self.privateKey=[[LWKeychainManager instance] privateKeyForWalletAddress:self.address];
    if(self.privateKey==nil && self.isColdStorageWallet==NO && [self.address isEqualToString:[LWPrivateKeyManager addressFromPrivateKeyWIF:[LWPrivateKeyManager shared].wifPrivateKeyLykke]])
    {
        self.privateKey=[LWPrivateKeyManager shared].wifPrivateKeyLykke;
    }
    if(!self.privateKey && self.isColdStorageWallet==NO)
    {
        self.privateKey=[[LWPrivateKeyManager shared] secondaryPrivateKeyFromPrivateWalletAddress:self.address];

    }
    
        
        double CurrentTime2 = CACurrentMediaTime();
NSLog(@"time %f found %@ name %@", CurrentTime2-CurrentTime1, self.privateKey, self.name);
    
        });
    
    
    return self;
}


@end
