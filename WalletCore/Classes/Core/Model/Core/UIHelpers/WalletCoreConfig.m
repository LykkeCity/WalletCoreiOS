//
//  WalletCoreConfig.m
//  WalletCore
//
//  Created by Georgi Stanev on 2.12.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

#import "WalletCoreConfig.h"
#import "LWConstantsLykke.h"

@implementation WalletCoreConfig

static NSString *_partnerId;

static WalletCoreTestingServer _testingServer = WalletCoreTestingServerDevelop;

+ (NSString *)partnerId {
    if (_partnerId == nil) {
        _partnerId = @"";
    }
    return _partnerId;
}

+ (void)setPartnerId:(NSString *)newPartner {
    if (_partnerId != newPartner) {
        _partnerId = [newPartner copy];
    }
}

+ (NSString *)testingServer{
    switch (_testingServer) {
        case WalletCoreTestingServerTest:
            return kTestingTestServer;
            
        case WalletCoreTestingServerStaging:
            return kStagingTestServer;
            
        default:
            return kDevelopTestServer;
    }
}

+ (void)configure:(NSString*) partnerId {
    WalletCoreConfig.partnerId = partnerId;
}

+ (void)configurePartnerId:(NSString *)partnerId testingServer:(WalletCoreTestingServer)testingServer {
    WalletCoreConfig.partnerId = partnerId;
    _testingServer = testingServer;
}

@end
