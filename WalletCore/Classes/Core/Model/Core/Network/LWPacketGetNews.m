//
//  LWPacketGetNews.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 30/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketGetNews.h"
#import "LWNewsElementModel.h"

@implementation LWPacketGetNews

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    for(NSDictionary *d in result)
    {
//        if([(NSArray *)result indexOfObject:d]==0)
//            continue;
        LWNewsElementModel *m=[[LWNewsElementModel alloc] initWithDictionary:d];
        [arr addObject:m];
    }
    if(self.completion)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completion(arr);
            });
    }
}

- (NSString *)urlRelative {
    return @"LykkeNews";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}


@end
