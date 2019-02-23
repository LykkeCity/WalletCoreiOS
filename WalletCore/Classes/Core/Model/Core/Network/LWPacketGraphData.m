//
//  LWPacketGraphData.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 12/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketGraphData.h"
#import "LWGraphPeriodModel.h"

@implementation LWPacketGraphData

#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    BOOL flagReverted=[result[@"Rate"][@"Inverted"] boolValue];
    
    self.startDate=[self dateFromString:result[@"StartTime"]];
    
    self.endDate=[self dateFromString:result[@"EndTime"]];
    self.fixingTime=[self dateFromString:result[@"FixingTime"]];
    
//    self.percentChange=[NSNumber numberWithDouble:[result[@"Rate"][@"PChange"] doubleValue]];
//    self.lastPrice=[NSNumber numberWithFloat:[result[@"LastPrice"] floatValue]];
    
//    self.lastPrice = [NSNumber numberWithFloat:0];
    
//    if(flagReverted)
//    {
////        a-старый курс   b-новый курс
////        
////        (b-a)/a=p  —>  b/a - 1 = p —>  a/b = 1 / (p+1)
////        
////        (1/b-1/a)*a=x —> a/b - 1 = x
////        
////        
////        x = 1/(p+1) - 1
//        
//        
//        double ppp=self.percentChange.doubleValue/100;
//        self.percentChange=@((1.0/(ppp+1)-1)*100);
//
////        self.lastPrice=@(1/self.lastPrice.doubleValue);
//        
//    }
    
    
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    
    NSTimeInterval lastTime=[NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval firstTime=0;//=lastTime-60*60*24*30;  //one month ago
    if([_period.value isEqualToString:@"1M"])
        firstTime=lastTime-60*60*24*30;  //one month ago
    else if([_period.value isEqualToString:@"1Y"])
        firstTime=lastTime-60*60*24*365;  //one year ago
    else if([_period.value isEqualToString:@"1H"])
        firstTime=lastTime-60*60;  //one hour ago
    else if([_period.value isEqualToString:@"1D"])
        firstTime=lastTime-60*60*24;  //one day ago
    else if([_period.value isEqualToString:@"3D"])
        firstTime=lastTime-60*60*24*3;  //one day ago
    
    
    double step=((double)lastTime-firstTime)/[result[@"Rate"][@"AskBidGraph"] count];
    
    for(int i=0;i<[result[@"Rate"][@"AskBidGraph"] count]; i++)
    {
        NSDictionary *s=result[@"Rate"][@"AskBidGraph"][i];
        double ask=[s[@"A"] doubleValue];
        double bid=[s[@"B"] doubleValue];
        
//        if(ask == 0) {
//            ask = 0.000000001;
//        }
        
//        NSLog(@"before %f %f", ask, bid);

//        if(i<157)
//            bid=0;
//        bid=0;
        
//        if(i>30 && i<40) {
//            ask = 0;
//        }
//        
//        if(i>100 && i<102) {
//            bid = 0;
//        }
//        
        
        if(flagReverted)
        {
//            double tmp=1/ask;
//            ask=1/bid;
//            bid=tmp;
            
            if(ask != 0 && bid != 0) {
                double tmp = ask;
                ask = 1/bid;
                bid = 1/tmp;
            }
            else {
                
                if(ask == 0 && bid != 0) {
                    ask = 1/bid;
                    bid = 0;
                }
                else if(bid == 0 && ask != 0) {
                    bid = 1/ask;
                    ask = 0;
                }
            }

            
            
//            if(ask>0)
//                ask=1.0/ask;
//            if(bid>0)
//                bid=ask-fabs(ask-1.0/bid);
//            if(ask == 0) {
//                ask = -bid;
//                bid = 0;
//            }

            
            
            
        }
        
//        NSLog(@"%f %f %d", ask, bid, (int)[result[@"Rate"][@"AskBidGraph"] indexOfObject:s]);

        
//        NSNumber *num=[NSNumber numberWithDouble:[s doubleValue]];
//        if(flagReverted)
//            num=[NSNumber numberWithDouble:1/[s doubleValue]];
//        
        
//        NSNumber *num1=@(num.doubleValue/100+num.doubleValue);
        
        
        
        [arr addObject:@{@"Bid":@(bid), @"Ask":@(ask), @"Time":@((NSTimeInterval)(step*i+firstTime))}];
    }
    
    self.graphValues=arr;
    
    double first;
    if([arr.firstObject[@"Bid"] doubleValue] == 0 || [arr.firstObject[@"Ask"] doubleValue] == 0) {
        first = [arr.firstObject[@"Bid"] doubleValue] + [arr.firstObject[@"Ask"] doubleValue];
    }
    else {
        first = ([arr.firstObject[@"Bid"] doubleValue] + [arr.firstObject[@"Ask"] doubleValue]) / 2;
    }
    
    double last;
    if([arr.lastObject[@"Bid"] doubleValue] == 0 || [arr.lastObject[@"Ask"] doubleValue] == 0) {
        last = [arr.lastObject[@"Bid"] doubleValue] + [arr.lastObject[@"Ask"] doubleValue];
    }
    else {
        last = ([arr.lastObject[@"Bid"] doubleValue] + [arr.lastObject[@"Ask"] doubleValue]) / 2;
    }
    
    _absChange = @(last - first);
    _percentChange = @(((last - first)/first)*100);

}



- (NSString *)urlRelative {
    return @"AssetPairDetailedRates?withBid=true";
}

-(NSDictionary *) params
{
    
//    return @{@"period":self.period.value, @"assetId":self.assetId, @"points":@(160)};
    return @{@"period":self.period.value, @"assetId":self.assetId, @"points":@(_points)};

}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
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
