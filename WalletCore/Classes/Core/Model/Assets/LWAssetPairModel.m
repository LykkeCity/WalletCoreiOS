//
//  LWAssetPairModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 04.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAssetPairModel.h"
#import "LWUtils.h"
#import "LWCache.h"

@interface LWAssetPairModel()
{
    BOOL isInverted;
}

@end


@implementation LWAssetPairModel


+(LWAssetPairModel *) assetPairWithDict:(NSDictionary *) dict {
    
    
    if([LWCache instance].allAssetPairs == nil) {
        [LWCache instance].allAssetPairs = [[NSMutableArray alloc] init];
    }
    
    NSMutableArray *arr=[LWCache instance].allAssetPairs;
    for(LWAssetPairModel *m in arr) {
        if([m.identity isEqualToString:dict[@"Id"]]) {
            [m updateWithDict:dict];
            return m;
        }
    }
    
    LWAssetPairModel *m=[[LWAssetPairModel alloc] init];
    [arr addObject:m];
    [m updateWithDict:dict];
    
    return m;
        
}


#pragma mark - LWJSONObject

- (void) updateWithDict:(id)json {
    isInverted=false;
        _identity = [json objectForKey:@"Id"];
        _group    = [json objectForKey:@"Group"];

        _accuracy = [json objectForKey:@"Accuracy"];
        _baseAssetId    = [json objectForKey:@"BaseAssetId"];
        _originalBaseAsset=_baseAssetId;
        _quotingAssetId = [json objectForKey:@"QuotingAssetId"];
        
        _normalAccuracy=_accuracy;
        _invertedAccuracy = [json objectForKey:@"InvertedAccuracy"];
        self.inverted=[[json objectForKey:@"Inverted"] boolValue];

    
    
}

-(void) setRate:(LWAssetPairRateModel *)rate
{
    if(_rate == nil) {
        self.inverted = rate.inverted;
    }
    else {
        if(rate.inverted != isInverted) {
            [rate invert];
        }
    }
    _rate=rate;
}

-(void) setInverted:(BOOL)inverted
{
    if(isInverted!=inverted)
    {
        isInverted=inverted;
        id tmpID=_baseAssetId;
        _baseAssetId=_quotingAssetId;
        _quotingAssetId=tmpID;
        if(isInverted)
            _accuracy=_invertedAccuracy;
        else
            _accuracy=_normalAccuracy;
        if(_rate.inverted != inverted) {
            [_rate invert];
        }
        
    }
    
    _name=[NSString stringWithFormat:@"%@/%@", [LWUtils baseAssetTitle:self], [LWUtils quotedAssetTitle:self]];

}

-(NSString *) baseAssetDisplayId {
    return [LWCache displayIdForAssetId:_baseAssetId];
}

-(NSString *) quotingAssetDisplayId {
    return [LWCache displayIdForAssetId:_quotingAssetId];
}

-(BOOL) inverted
{
    return isInverted;
}

@end
