//
//  NSDate+String.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 11.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "NSDate+String.h"


@implementation NSDate (String)

- (NSString *)toShortFormat {
    NSString *dateString = [NSDateFormatter
                            localizedStringFromDate:self
                            dateStyle:NSDateFormatterShortStyle
                            timeStyle:NSDateFormatterShortStyle];
    return dateString;
}

-(NSString *) timePassedFromDate:(NSDate *) date
{
    
    NSTimeInterval interval=[self timeIntervalSinceDate:date];
    int years=interval/(365*24*60*60);
    int months=interval/(30*24*60*60);
    int weeks=interval/(7*24*60*60);
    int days=interval/(24*60*60);
    int hours=interval/(60*60);
    int minutes=interval/60;
    
    int res;
    NSString *ttt;
    if(years)
    {
        ttt=@"year";
        res=years;
    }
    else if(months)
    {
        res=months;
        ttt=@"month";
    }
    else if(weeks)
    {
        res=weeks;
        ttt=@"week";
    }
    else if(days)
    {
        res=days;
        ttt=@"day";
    }
    else if(hours)
    {
        res=hours;
        ttt=@"hour";
    }
    else if(minutes)
    {
        res=minutes;
        ttt=@"minute";
    }
    else
    {
        res=0;
    }
    
    NSString *result;
    if(res)
    {
        result=[NSString stringWithFormat:@"%d %@",res, ttt];
        if(res>1)
            result=[result stringByAppendingString:@"s"];
        result=[result stringByAppendingString:@" ago"];
    }
    else
        result=@"Now";
    
    return result;
}

@end
