//
//  LWStringUtils.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 04.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWStringUtils.h"
#import "LWMath.h"


@implementation LWStringUtils

+ (NSString *)formatCreditCard:(NSString *)input
{
    input = [[self class] trimSpecialCharacters:input];
    NSString *output;
    switch (input.length) {
        case 1:
        case 2:
        case 3:
        case 4:
            output = [NSString stringWithFormat:@"%@", [input substringToIndex:input.length]];
            break;
        case 5:
        case 6:
        case 7:
        case 8:
            output = [NSString stringWithFormat:@"%@ %@", [input substringToIndex:4], [input substringFromIndex:4]];
            break;
        case 9:
        case 10:
        case 11:
        case 12:
            output = [NSString stringWithFormat:@"%@ %@ %@", [input substringToIndex:4], [input substringWithRange:NSMakeRange(4, 4)], [input substringFromIndex:8]];
            break;
        case 13:
        case 14:
        case 15:
        case 16:
            output = [NSString stringWithFormat:@"%@ %@ %@ %@", [input substringToIndex:4], [input substringWithRange:NSMakeRange(4, 4)], [input substringWithRange:NSMakeRange(8, 4)], [input substringFromIndex:12]];
            break;
        default:
            output = @"";
            break;
    }
    return output;
}

+ (NSString *)formatCreditCardExpiry:(NSString *)input shouldRemoveText:(BOOL)shouldRemoveText
{
    input = [[self class] trimSpecialCharacters:input];
    NSString *output;
    switch (input.length) {
        case 1:
        {
            NSNumber *value = [LWMath number:input];
            if (value.intValue > 2) {
                output = [NSString stringWithFormat:@"0%@/", value];
            }
            else {
                output = input;
            }
            break;
        }
        case 2:
        {
            if (shouldRemoveText) {
                output = [NSString stringWithFormat:@"%@", [input substringToIndex:2]];
            }
            else {
                output = [NSString stringWithFormat:@"%@/", [input substringToIndex:input.length]];
            }
            break;
        }
        case 3:
        case 4:
            output = [NSString stringWithFormat:@"%@/%@", [input substringToIndex:2], [input substringFromIndex:2]];
            break;
        default:
            output = @"";
            break;
    }
    return output;
}

+ (NSString *)trimSpecialCharacters:(NSString *)input
{
    NSCharacterSet *special = [NSCharacterSet characterSetWithCharactersInString:@"/+-() "];
    return [[input componentsSeparatedByCharactersInSet:special] componentsJoinedByString:@""];
}

+ (NSNumber *)monthFromExpiration:(NSString *)input {
    NSString *month = [input substringToIndex:2];
    NSNumber *result = @([month intValue]);
    return result;
}

+ (NSNumber *)yearFromExpiration:(NSString *)input {
    NSString *year = [input substringFromIndex:3];
    NSNumber *result = @([year intValue]);
    return result;
}

@end
