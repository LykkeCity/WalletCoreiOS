//
//  LWMWHistoryElement.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 17/01/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWMWHistoryElement.h"
#import "LWUtils.h"
#import "LWCache.h"

@implementation LWMWHistoryElement


-(NSString *) positionString {
    double v = fabs(self.volume);
    NSMutableString *string = [NSMutableString new];
    if(self.volume > 0) {
        [string appendString:@"LONG "];
    }
    else {
        [string appendString:@"SHORT "];
    }
    [string appendString:[LWUtils formatVolume:v accuracy:self.accuracy]];
    [string appendString:@" at "];
    if(_type == CLOSE) {
        [string appendString:[LWUtils formatVolume:self.closePrice accuracy:self.accuracy]];
    }
    else {
        [string appendString:[LWUtils formatVolume:self.openPrice accuracy:self.accuracy]];

    }
    return string;
}

-(NSString *) closeReasonString
{
    if(_type == OPEN) {
        return @"Open";
    }
    if(self.closeReason == STOP_LOSS) {
        return @"Close/SL ";
    }
    else if(self.closeReason == TAKE_PROFIT) {
        return @"Close/TP ";
    }
    else if(self.closeReason == MARGIN) {
        return @"Margin Call ";
    }
    else {
        return @"Close ";
    }
}

@end
