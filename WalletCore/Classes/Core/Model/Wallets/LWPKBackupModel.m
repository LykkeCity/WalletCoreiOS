//
//  LWPKBackupModel.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 01/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPKBackupModel.h"
#import "LWPrivateKeyManager.h"

@implementation LWPKBackupModel

-(void) setPrivateKeyWif:(NSString *)privateKeyWif
{
    _privateKeyWif=privateKeyWif;
    if(_passPhrase && _privateKeyWif)
        [self encode];
}

-(void) setPassPhrase:(NSString *)passPhrase
{
    _passPhrase=passPhrase;
    if(_passPhrase && _privateKeyWif)
        [self encode];
}

-(void) encode
{
    _encodedKey=[LWPrivateKeyManager encodedPrivateKeyWif:_privateKeyWif withPassPhrase:_passPhrase];
}

@end
