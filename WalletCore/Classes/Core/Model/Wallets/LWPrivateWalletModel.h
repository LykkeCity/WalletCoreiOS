//
//  LWPrivateWalletModel.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWPrivateWalletModel : NSObject

-(id) initWithDict:(NSDictionary *) dict;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *privateKey;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSArray *assets;
@property (strong, nonatomic) NSString *iconURL;
@property (strong, nonatomic) NSString *encryptedKey;
@property BOOL isExternalWallet;
@property BOOL isColdStorageWallet;

@end
