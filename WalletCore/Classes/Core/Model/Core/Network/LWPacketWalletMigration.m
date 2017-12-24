//
//  LWPacketWalletMigration.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 24/09/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketWalletMigration.h"
#import "LWWalletMigrationModel.h"

@implementation LWPacketWalletMigration

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}

- (NSString *)urlRelative {
    return [NSString stringWithFormat:@"WalletMigration"];
}

-(NSDictionary *) params
{
    NSDictionary *params=@{@"SourcePrivateKey":_migration.fromPrivateKey, @"PubKey":_migration.toPubKey, @"EncodedPrivateKey":_migration.toEncodedPrivateKey, @"PrivateKey":_migration.toPrivateKey};
    NSLog(@"Migrating to: %@", params);
    return params;
}


@end
