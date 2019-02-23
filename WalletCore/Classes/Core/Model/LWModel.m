//
//  LWModel.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 17/01/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWModel.h"

@implementation LWModel

-(id) removeNulls:(id)dict
{
    if([dict isKindOfClass:[NSArray class]]) {
        return [self checkArrayResult:dict];
    }
    if([dict isKindOfClass:[NSDictionary class]])
    {
        NSMutableDictionary *checkedResult=[dict mutableCopy];
        [self checkResult:checkedResult];

        return checkedResult;
    }
    
    return nil;
    
}


-(NSArray *) checkArrayResult:(NSArray *) resArray
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    dict[@"array"]=resArray;
    [self checkResult:dict];
    return dict[@"array"];
}

-(void) checkResult:(NSMutableDictionary *) resultDict
{
    NSArray *keys=[resultDict allKeys];
    for(NSString *k in keys)
    {
        id object=resultDict[k];
        if([object isKindOfClass:[NSNull class]])
        {
            [resultDict removeObjectForKey:k];
        }
        if([object isKindOfClass:[NSDictionary class]])
        {
            NSMutableDictionary *newDict=[object mutableCopy];
            [self checkResult:newDict];
            resultDict[k]=newDict;
        }
        if([object isKindOfClass:[NSArray class]])
        {
            NSMutableArray *newArr=[object mutableCopy];
            for(int i=0;i<[newArr count];i++)
            {
                id arrElement=newArr[i];
                if([arrElement isKindOfClass:[NSNull class]])
                {
                    [newArr removeObjectAtIndex:i];
                    i--;
                }
                else if([arrElement isKindOfClass:[NSDictionary class]])
                {
                    NSMutableDictionary *newDict=[arrElement mutableCopy];
                    [self checkResult:newDict];
                    [newArr replaceObjectAtIndex:i withObject:newDict];
                    
                }
                
            }
            resultDict[k]=newArr;
        }
    }
}

-(NSDate *) dateFromString:(NSString *) string
{
    string=[string stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    string=[string substringWithRange:NSMakeRange(0, 19)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone=[NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"UTC"]];
    NSDate *date = [dateFormatter dateFromString:string];
    
    return date;
}


@end
