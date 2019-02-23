//
//  LWPacketCheckIsUSAUser.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/03/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWPacketCheckIsUSAUser.h"

@implementation LWPacketCheckIsUSAUser

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    _isUserFromUSA = [[result objectForKey:@"IsUsOrCanadaPhoneNum"] boolValue];
    NSLog(@"%@", response);
    
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}



- (NSString *)urlRelative {
    
    
    NSString *urlStr = [@"Utils/isUSorCanadaNumber/" stringByAppendingString:_phoneNumber];
    
    return urlStr;
}

@end
