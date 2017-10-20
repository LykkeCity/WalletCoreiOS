//
//  LWPKBackupModel.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 01/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWPKBackupModel : NSObject

@property (strong, nonatomic) NSString *privateKeyWif;
@property (strong, nonatomic) NSString *walletName;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *passPhrase;
@property (strong, nonatomic) NSString *hint;
@property (readonly, nonatomic) NSString *encodedKey;


@end
