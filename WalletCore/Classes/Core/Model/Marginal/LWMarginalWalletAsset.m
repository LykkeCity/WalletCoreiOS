//
//  LWMarginalWalletAsset.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/12/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMarginalWalletAsset.h"
#import "LWMarginalAccount.h"

@interface LWMarginalWalletAsset()
{
    double savedDeltaAsk;
    double savedDeltaBid;
    NSDictionary *origDict;
}

@end

@implementation LWMarginalWalletAsset

-(id) init
{
    self=[super init];
    
    _changes=[[NSMutableArray alloc] init];
    _graphValues = [[NSMutableArray alloc] init];

    
    savedDeltaAsk = 0;
    savedDeltaBid = 0;
    
    return self;
}

-(id) initWithDict:(NSDictionary *)d
{
    self=[super init];
    
    origDict = d;
    
    _graphValues = [[NSMutableArray alloc] init];

    _identity=d[@"Id"];
    _name=d[@"Name"];
    _accuracy=[d[@"Accuracy"] intValue];


    _changes=[[NSMutableArray alloc] init];
    
    _baseAssetId=d[@"BaseAssetId"];
    _quotingAssetId=d[@"QuoteAssetId"];

    
    return self;
}

-(LWMarginalWalletAsset *) copy {
    LWMarginalWalletAsset *newAsset = [[LWMarginalWalletAsset alloc] initWithDict:origDict];
    return newAsset;
}

-(void) updateWithDict:(NSDictionary *)d {
    
    _leverage=[d[@"LeverageInit"] doubleValue];
    _leveragHigher=[d[@"LeverageMaintenance"] doubleValue];
    _swapLong = -[d[@"SwapLong"] doubleValue];
    _swapShort = -[d[@"SwapShort"] doubleValue];
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

- (BOOL)ratesChanged:(NSArray *)newRates {
	if (!newRates.count) {
		return NO;
	}
	
	LWMarginalWalletRate *previousRate = newRates.count > 1 ? newRates[newRates.count - 2] : _rate;
	LWMarginalWalletRate *newRate = newRates[newRates.count - 1];
	
	BOOL changed = YES;
	if (newRates.count == 1 && previousRate && (previousRate.ask != newRate.ask || previousRate.bid != newRate.bid)) {
		changed = YES;
	}
	
	@synchronized (self) {
		NSMutableArray *newChanges = [_changes mutableCopy];
		[newChanges addObjectsFromArray:newRates];
		
		_previousRate = previousRate;
		_rate = newRate;
		
		if (_rate.ask > _previousRate.ask) {
			_askRaising = YES;
		}
		else if (_rate.ask < _previousRate.ask) {
			_askRaising = NO;
		}
		
		if (_rate.bid > _previousRate.bid) {
			_bidRaising = YES;
		}
		else if (_rate.bid < _previousRate.bid) {
			_bidRaising = NO;
		}
		
		NSInteger maxRatesCount = 500;
		NSInteger count = MIN(maxRatesCount, newChanges.count);
		NSInteger start = newChanges.count - count;
		_changes = [newChanges subarrayWithRange:NSMakeRange(start, count)].mutableCopy;
		
		double maxValue = 0;
		double minValue = LONG_MAX;
		
		for (LWMarginalWalletRate *r in _changes) {
			if (r.bid < minValue && r.bid > 0) {
				minValue = r.bid;
			}
			if (r.ask < minValue) {
				minValue = r.ask;
			}
			if (r.ask > maxValue) {
				maxValue=r.ask;
			}
		}
		
		NSMutableArray *arr = @[].mutableCopy;
		for (int index = 0; index < _changes.count; index++) {
			LWMarginalWalletRate *r = _changes[index];
			
			if (index < (int)_changes.count - 150) {
				continue;
			}
			
			double value = r.bid > 0 ? (r.ask + r.bid)/2 : r.ask;
			
			if (maxValue == minValue) {
				[arr addObject:@(0.5)];
			}
			else {
				[arr addObject:@((value-minValue) / (maxValue-minValue))];
			}
		}
		_graphValues=arr;
	}
	return changed;
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
