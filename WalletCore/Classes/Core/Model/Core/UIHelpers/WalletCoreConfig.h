//
//  WalletCoreConfig.h
//  WalletCore
//
//  Created by Georgi Stanev on 2.12.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WalletCoreTestingServer) {
    WalletCoreTestingServerDevelop,
    WalletCoreTestingServerTest,
    WalletCoreTestingServerStaging
};

@interface WalletCoreConfig : NSObject

@property (class, readonly, nonatomic) NSString *partnerId;

@property (class, readonly, nonatomic) NSString *testingServer;
@property (class, readonly, nonatomic) NSString *blueTestingServer;

+ (void)configure:(NSString*) partnerId;

+ (void)configurePartnerId:(NSString *)partnerId testingServer:(WalletCoreTestingServer)testingServer;

@end
