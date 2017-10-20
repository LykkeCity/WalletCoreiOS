//
//  LWMarginalWalletAsset.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/12/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMarginalWalletAsset.h"

@interface LWMarginalWalletAsset()
{
    double savedDeltaAsk;
    double savedDeltaBid;
}

@end

@implementation LWMarginalWalletAsset

-(id) init
{
    self=[super init];
    
    _changes=[[NSMutableArray alloc] init];
    _graphValues = [[NSMutableArray alloc] init];
    _belongsToAccounts = [[NSMutableArray alloc] init];
    
    savedDeltaAsk = 0;
    savedDeltaBid = 0;
    
    return self;
}

-(id) initWithDict:(NSDictionary *)d
{
    self=[super init];
    
    _graphValues = [[NSMutableArray alloc] init];
    _belongsToAccounts = [[NSMutableArray alloc] init];

    _identity=d[@"Id"];
    _name=d[@"Name"];
    _accuracy=[d[@"Accuracy"] intValue];


    _changes=[[NSMutableArray alloc] init];
    
    _baseAssetId=d[@"BaseAssetId"];
    _quotingAssetId=d[@"QuoteAssetId"];

//    _name=d[@"Name"];
//    _accuracy=[d[@"Accuracy"] intValue];
//    _leverage=[d[@"LeverageInit"] doubleValue];
//    _leveragHigher=[d[@"LeverageMaintenance"] doubleValue];
//    
//    _swapLong = [d[@"SwapLong"] doubleValue];
//    _swapShort = [d[@"SwapShort"] doubleValue];
//    
//    
//    double mult = 1;
//    for(int i=0;i<_accuracy;i++) {
//        mult = mult * 0.1;
//    }
//    savedDeltaAsk = [d[@"DeltaAsk"] doubleValue] * mult;
//    savedDeltaBid = [d[@"DeltaBid"] doubleValue] * mult;
//    
    

//    [self updateWithDict:d];

    
    return self;
}

-(void) updateWithDict:(NSDictionary *)d {
    
    _leverage=[d[@"LeverageInit"] doubleValue];
    _leveragHigher=[d[@"LeverageMaintenance"] doubleValue];
    _swapLong = [d[@"SwapLongPct"] doubleValue];
    _swapShort = [d[@"SwapShortPct"] doubleValue];
    double mult = 1;
    for(int i=0;i<_accuracy;i++) {
        mult = mult * 0.1;
    }
    savedDeltaAsk = [d[@"DeltaAsk"] doubleValue] * mult;
    savedDeltaBid = [d[@"DeltaBid"] doubleValue] * mult;

    _baseAssetName=@"";
    NSArray *components=[_name componentsSeparatedByString:@"/"];
    if(components.count==2)
        _baseAssetName=components[0];

}

-(BOOL) rateChanged:(LWMarginalWalletRate *)newRate
{
    if(_rate && newRate.ask == _rate.ask && newRate.bid == _rate.bid) {
        return NO;
    }
    @synchronized (self) {

    NSMutableArray *newChanges=[_changes mutableCopy];
        [newChanges addObject:newRate];
        _previousRate=_rate;
        _rate=newRate;
        if(_rate.ask>_previousRate.ask)
            _askRaising=YES;
        else if(_rate.ask<_previousRate.ask)
            _askRaising=NO;
        if(_rate.bid>_previousRate.bid)
            _bidRaising=YES;
        else if(_rate.bid<_previousRate.bid)
            _bidRaising=NO;
        
        
        if(newChanges.count>500)
            [newChanges removeObjectAtIndex:0];
        _changes=newChanges;


    double maxValue=0;
    double minValue=LONG_MAX;
    
    for(LWMarginalWalletRate *r in _changes)
    {
        if(r.bid<minValue && r.bid>0)
            minValue=r.bid;
        if(r.ask<minValue)
            minValue=r.ask;

        if(r.ask>maxValue)
            maxValue=r.ask;
    }
    NSMutableArray *arr=[NSMutableArray new];
    for(LWMarginalWalletRate *r in _changes)
    {
        int index = (int)[_changes indexOfObject:r];
        if(index < (int)_changes.count-150)
            continue;
        double value;
        if(r.bid>0)
            value=(r.ask+r.bid)/2;
        else
            value=r.ask;
        if(maxValue == minValue) {
            [arr addObject:@(0.5)];
        }
        else {
            [arr addObject:@((value-minValue)/(maxValue-minValue))];
        }
    }
    _graphValues=arr;
        
        
    }
    return YES;
}

-(double) deltaAsk {
    
    if(savedDeltaAsk == 0) {
        LWMarginalWalletRate *rate = _changes.lastObject;
        savedDeltaAsk = (rate.ask - rate.bid) / 2;

    }
    
    return savedDeltaAsk;
}

-(double) deltaBid {
    
    if(savedDeltaBid == 0) {
        LWMarginalWalletRate *rate = _changes.lastObject;
        savedDeltaBid = (rate.ask - rate.bid) / 2;
        
    }
    
    return savedDeltaBid;
}

@end
