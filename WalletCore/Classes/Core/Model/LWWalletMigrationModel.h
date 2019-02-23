//
//  LWWalletMigrationModel.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 24/09/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWWalletMigrationModel : NSObject

@property (strong, nonatomic) NSString *fromPrivateKey;
@property (strong, nonatomic) NSString *toPubKey;
@property (strong, nonatomic) NSString *toPrivateKey;
@property (strong, nonatomic) NSString *toEncodedPrivateKey;

@end
