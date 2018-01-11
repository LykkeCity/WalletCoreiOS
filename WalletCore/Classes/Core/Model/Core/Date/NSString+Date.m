//
//  NSString+Date.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 11.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "NSString+Date.h"

@implementation NSString (Date)

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        
        dateFormatter.timeZone=[NSTimeZone timeZoneWithName:@"UTC"];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier: @"en_US"];
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    });
    return dateFormatter;
}

- (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        
        dateFormatter.timeZone=[NSTimeZone timeZoneWithName:@"UTC"];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier: @"en_US"];
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    });
    return dateFormatter;
}

- (NSDate *)toDate {
    NSString *string=[self copy];
    string=[string stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    string=[string substringWithRange:NSMakeRange(0, 19)];
    
    return [[self dateFormatter] dateFromString:string];
}

- (NSDateFormatter *)millisecsDateFormatter {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];

        dateFormatter.timeZone=[NSTimeZone timeZoneWithName:@"UTC"];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier: @"en_US"];
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS 'z'"];
    });
    return dateFormatter;
}

- (NSDate *)toDateWithMilliSeconds {
    return [[self millisecsDateFormatter] dateFromString:self];
}

@end
