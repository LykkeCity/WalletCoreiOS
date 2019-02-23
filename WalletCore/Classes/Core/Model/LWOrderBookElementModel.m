//
//  LWOrderBookElementModel.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 09/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWOrderBookElementModel.h"

@interface LWOrderBookElementModel()
{
    NSArray *array;
    NSArray *origArray;
    NSArray *cumArray;
    BOOL flagCumulativeVolume;
    BOOL flagInverted;
}

@end

@implementation LWOrderBookElementModel

-(id) initWithArray:(NSArray *)arr
{
    self=[super init];
    flagCumulativeVolume=NO;
    origArray=arr;
    flagInverted=NO;
    
    [self fillWithOriginalValues];
    
    return self;
}

-(void) fillWithOriginalValues
{
    NSMutableArray *newarr=[[NSMutableArray alloc] init];
    NSMutableArray *newCumArr=[[NSMutableArray alloc] init];
    double sum=0;
    for(NSDictionary *d in origArray)
    {
        
        double value=fabs([d[@"Volume"] doubleValue]);
        sum+=value;
        
        [newarr addObject:@{@"Price":@([d[@"Price"] doubleValue]), @"Volume":@(value)}];
        [newCumArr addObject:@{@"Price":@([d[@"Price"] doubleValue]), @"Volume":@(sum)}];
    }
    array=newarr;
    cumArray=newCumArr;

}

-(void) setIsVolumeCumulative:(BOOL)isVolumeCumulative
{
    if(isVolumeCumulative==flagCumulativeVolume)
        return;
    flagCumulativeVolume=isVolumeCumulative;
}

-(BOOL) isVolumeCumulative
{
    return flagCumulativeVolume;
}

-(void) invert
{
    if(!origArray.count || flagInverted)
        return;
    
    flagInverted=YES;
    NSMutableArray *newarr=[[NSMutableArray alloc] init];
    NSMutableArray *newCumArr=[[NSMutableArray alloc] init];

    double sum=0;

    for(NSDictionary *d in origArray)
    {
        double value=fabs([d[@"Price"] doubleValue]*[d[@"Volume"] doubleValue]);
        sum+=value;

        NSDictionary *dict=@{@"Price":@((double)1.0/[d[@"Price"] doubleValue]), @"Volume":@(value)};
        [newarr addObject:dict];
        dict=@{@"Price":@((double)1.0/[d[@"Price"] doubleValue]), @"Volume":@(sum)};
        [newCumArr addObject:dict];
    }
    array=newarr;
    cumArray=newCumArr;
}

-(double) priceForVolume:(double)volumeOrig
{
    
    if(!array.count)
        return 0;

    if(volumeOrig==0)
        return [array[0][@"Price"] doubleValue];
    double amount=0;
    double volumeLeft=volumeOrig;
    for(NSDictionary *d in array)
    {
        double price=[d[@"Price"] doubleValue];
        double volume=[d[@"Volume"] doubleValue];
        if(volume<volumeLeft)
        {
            amount+=price*volume;
            volumeLeft-=volume;
        }
        else
        {
            amount+=price*volumeLeft;
            volumeLeft=0;
            break;
        }
    }
    if(volumeLeft>0)
        return amount/(volumeOrig-volumeLeft);
    
    
    return amount/volumeOrig;

}


-(double) priceForResult:(double)volumeOrig
{
    if(!array.count)
        return 0;

    if(volumeOrig==0)
        return [array[0][@"Price"] doubleValue];

    double amount=0;
    double lkkBought=0;
    for(NSDictionary *d in array)
    {
        double price=[d[@"Price"] doubleValue];
        double volume=[d[@"Volume"] doubleValue];
        if(price*volume+amount<volumeOrig)
        {
            amount+=price*volume;
            lkkBought+=volume;
        }
        else
        {
            lkkBought+=(volumeOrig-amount)/price;
            amount=volumeOrig;
            break;
        }
    }
//    if(amount<volumeOrig)
//        return ;
    
    
    return amount/lkkBought;
    
}

-(BOOL) isVolumeOK:(double) volume
{
    double amount=0;
    for(NSDictionary *d in array)
        amount+=[d[@"Volume"] doubleValue];
    return volume<=amount;
}


-(BOOL) isResultOK:(double) result
{
    double amount=0;
    for(NSDictionary *d in array)
        amount+=[d[@"Volume"] doubleValue]*[d[@"Price"] doubleValue];
    return result<=amount;

}


-(LWOrderBookElementModel *) copy
{
    LWOrderBookElementModel *m=[[LWOrderBookElementModel alloc] initWithArray:origArray];
    if(flagInverted)
        [m invert];
    
        m.isVolumeCumulative=flagCumulativeVolume;
    return m;
}

-(NSArray *) array
{
    if(flagCumulativeVolume==NO)
        return array;
    else
        return cumArray;
}


@end
