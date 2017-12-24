//
//  LWRegistrationData.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 11.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWRegistrationData.h"

@implementation LWRegistrationData

- (instancetype)copyWithZone:(NSZone *)zone
{
    LWRegistrationData* data = [[LWRegistrationData allocWithZone:zone] init];
    data.email = [self.email copy];
    data.fullName = [self.fullName copy];
    data.phone = [self.phone copy];
    data.password = [self.password copy];
    data.clientInfo = [self.clientInfo copy];
    data.passwordHint=[self.passwordHint copy];
    return data;
}

@end
