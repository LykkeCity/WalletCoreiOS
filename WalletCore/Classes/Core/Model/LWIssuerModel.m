//
//  LWIssuerModel.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 07/12/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWIssuerModel.h"
#import "LWImageDownloader.h"

@implementation LWIssuerModel


-(id) initWithDict:(NSDictionary *) dict
{
    self=[super init];
    _identity=dict[@"Id"];
    _name=dict[@"Name"];
    _iconUrl=dict[@"IconUrl"];
    
    [[LWImageDownloader shared] downloadImageFromURLString:_iconUrl shouldAuthenticate:NO withCompletion:^(UIImage *image){
        _icon=image;
    }];
    
    return self;
}


@end
