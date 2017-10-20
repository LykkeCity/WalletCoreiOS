//
//  LWSignRequestModel.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 05/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWSignRequestModel.h"

@implementation LWSignRequestModel

-(id) initWithDictionary:(NSDictionary *) dict
{
    self=[super init];
    
    _blockchain=dict[@"Blockchain"];
    _hashString=dict[@"Hash"];
    _address=dict[@"MultisigAddress"];
    _requestId=dict[@"RequestId"];
    
    
    return self;
}

@end
