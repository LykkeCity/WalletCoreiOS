//
//  WalletCoreConfig.h
//  WalletCore
//
//  Created by Georgi Stanev on 2.12.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WalletCoreConfig : NSObject

@property (class, copy, nonatomic) NSString *partnerId;

+ (void)configure:(NSString*) partnerId;

@end
