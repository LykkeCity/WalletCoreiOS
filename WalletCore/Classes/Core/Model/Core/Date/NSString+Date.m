//
//  NSString+Date.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 11.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "NSString+Date.h"


@implementation NSString (Date)

- (NSDate *)toDate {
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
//    [dateFormatter setTimeZone:gmt];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
//    NSDate *dateFromString = [[NSDate alloc] init];
//    dateFromString = [dateFormatter dateFromString:self];
//    return dateFromString;
    
    
    NSString *string=[self copy];
    string=[string stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    string=[string substringWithRange:NSMakeRange(0, 19)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone=[NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"UTC"]];
    NSDate *date = [dateFormatter dateFromString:string];
    
    return date;
}

- (NSDate *)toDateWithMilliSeconds {
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    //    [dateFormatter setTimeZone:gmt];
    //    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    //    NSDate *dateFromString = [[NSDate alloc] init];
    //    dateFromString = [dateFormatter dateFromString:self];
    //    return dateFromString;
    
    
    NSString *string=[self copy];
//    string=[string stringByReplacingOccurrencesOfString:@"T" withString:@" "];
//    string=[string substringWithRange:NSMakeRange(0, 19)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone=[NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSz"];
    //    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"UTC"]];
    NSDate *date = [dateFormatter dateFromString:string];
    
    return date;
}




@end
