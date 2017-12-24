//
//  LWDeviceInfo.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 23.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWDeviceInfo.h"
#import <UIKit/UIKit.h>
#import <UIDeviceIdentifier/UIDeviceHardware.h>
#import "LWCache.h"


@interface LWDeviceInfo () {
    
}


#pragma mark - Private

- (NSString *)deviceType;
- (NSString *)deviceModel;
- (NSString *)deviceOS;
- (NSString *)deviceScreen;

@end

@implementation LWDeviceInfo


SINGLETON_INIT_EMPTY

#pragma mark - Common

- (NSString *)clientInfo {
    return [NSString stringWithFormat:@"%@; Model:%@; Os:%@; Screen:%@",
            [self deviceType], [self deviceModel], [self deviceOS], [self deviceScreen]];
}


#pragma mark - Private

- (NSString *)deviceType {
    NSString *model = [UIDeviceHardware platformStringSimple];
    
    NSRange const range = [model rangeOfString:@" "];
    if (range.location != NSNotFound) {
        return [model substringToIndex:range.location];
    }
    return model;
}

- (NSString *)deviceModel {
    NSString *model = [UIDeviceHardware platformStringSimple];
    
    NSRange const range = [model rangeOfString:@" "];
    if (range.location != NSNotFound) {
        return [model substringFromIndex:range.location + 1];
    }
    return @"-";
}

- (NSString *)deviceOS {
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString *)deviceScreen {
    CGSize const size = [UIScreen mainScreen].bounds.size;
    return [NSString stringWithFormat:@"%dx%d", (int)size.width, (int)size.height];
}

@end
