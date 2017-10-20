//
//  LWPacketWallets.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 26.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacketWallets.h"
#import "LWCache.h"


@implementation LWPacketWallets


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    NSLog(@"Finished loading wallets");

    _data = [[LWLykkeWalletsData alloc] initWithJSON:result];
    [LWCache instance].walletsData=_data.lykkeData;
    NSLog(@"Finished parsing wallets");

}

- (NSString *)urlRelative {
    NSLog(@"Started loading wallets");
    return @"Wallets";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
