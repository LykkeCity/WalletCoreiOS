//
//  LWPacketSaveBackupState.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketSaveBackupState.h"

@implementation LWPacketSaveBackupState

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
}


- (NSString *)urlRelative {
    return @"BackupCompleted";
}


@end
