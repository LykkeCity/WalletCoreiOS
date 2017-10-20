//
//  LWWatchList.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 27/12/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWWatchList.h"
#import "LWMarginalWalletsDataManager.h"
#import "LWMarginalWalletAsset.h"
#import "LWWatchListElement.h"
#import "LWCache.h"
#import "LWMarginalAccount.h"

@interface LWWatchList ()
{
    NSMutableArray *elements;
}
@end

@implementation LWWatchList


-(id) init
{
    self=[super init];
    _name=@"";
    elements=[[NSMutableArray alloc] init];
    _order = 0;
    return self;
}

-(void) updateWithDict:(NSDictionary *) dict {
    _name=dict[@"Name"];
    
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    if(_type == CFD) {
        NSArray *assets=[LWMarginalWalletsDataManager shared].allAssets;
        for(NSString *s in dict[@"AssetIds"])
        {
            for(LWMarginalWalletAsset *asset in assets)
            {
                if([asset.identity isEqualToString:s])
                {
                    LWWatchListElement *element=[[LWWatchListElement alloc] initWithMarginalAsset:asset];
                    [arr addObject:element];
                }
            }
        }
        
        _accountId = dict[@"AccountId"];
        
    }
    else {
        NSArray *assets=[LWCache instance].allAssetPairs;
        for(NSString *s in dict[@"AssetIds"])
        {
            for(LWAssetPairModel *asset in assets)
            {
                if([asset.identity isEqualToString:s])// && asset.rate != nil)
                {
                    LWWatchListElement *element=[[LWWatchListElement alloc] initWithSpotAssetPair:asset];
                    [arr addObject:element];
                }
            }
        }
        
    }
    
    _order = [dict[@"Order"] intValue];
    elements=arr;
    _identity = dict[@"Id"];
    
    _readOnly = [dict[@"ReadOnly"] boolValue];

    
}

-(id) initWithDict:(NSDictionary *) dict type:(WATCH_LIST_TYPE)type
{
    self=[super init];
    _type = type;
    
    [self updateWithDict:dict];
    
    
    return self;
}

-(void) setIsSelected:(BOOL)isSelected {
//    if(_identity == nil && _type == SPOT) {
//            _identity = [[NSUUID UUID] UUIDString];
//        
//    }
    if(!_identity) {
        return;
    }
    NSString *key;
    if(_type == CFD) {
        key = @"SelectedCFDWatchListId";
    }
    else {
        key = @"SelectedSPOTWatchListId";
    }
    if(isSelected) {
        [[NSUserDefaults standardUserDefaults] setObject:_identity forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];

    } else {
        if([[[NSUserDefaults standardUserDefaults] objectForKey:key] isEqualToString:_identity]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
}

-(BOOL) isSelected {
    NSString *key;
    if(_type == CFD) {
        key = @"SelectedCFDWatchListId";
    }
    else {
        key = @"SelectedSPOTWatchListId";
    }

    return [[[NSUserDefaults standardUserDefaults] objectForKey:key] isEqualToString:_identity];
}

-(NSDictionary *) dictionary
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    dict[@"Name"]=_name;
    NSMutableArray *assetIds=[[NSMutableArray alloc] init];
    for(LWWatchListElement *asset in elements)
    {
        [assetIds addObject:asset.assetId];
    }
    
    dict[@"AssetIds"]=assetIds;
    
    if(_type == CFD) {
        dict[@"AccountId"] = _accountId;
    }
//    else {
//        if(!_identity) {
//            _identity = [[NSUUID UUID] UUIDString];
//        }
//    }
    
    
    
    if(_identity) {
        dict[@"Id"] = _identity;
    }

    dict[@"Order"] = @(_order);

    
    
    return dict;
}


-(NSMutableArray *) elements {
    if(_type == CFD) {
        NSMutableArray *filteredElements = [[NSMutableArray alloc] init];
        LWMarginalAccount *account = [LWMarginalWalletsDataManager shared].currentAccount;
        for(LWWatchListElement *a in elements) {
            if([[(LWMarginalWalletAsset *)a.asset belongsToAccounts] containsObject:account.baseAssetId]) {
                [filteredElements addObject:a];
            }
        }
        return filteredElements;
    }
    else {
        return elements;
    }
}

-(LWWatchList *) copy {
    LWWatchList *newWatchList = [[LWWatchList alloc] init];
    newWatchList.accountId = _accountId;
    for(LWWatchListElement *e in elements) {
        [newWatchList addElement:e];
    }

    newWatchList.readOnly = NO;
    newWatchList.isSelected = NO;
    newWatchList.order = 0;
    newWatchList.type = _type;
    
    return newWatchList;
}

-(void) addElement:(LWWatchListElement *)element {
    [elements addObject:element];
}

-(void) removeElement:(LWWatchListElement *)element {
    [elements removeObject:element];
}


-(void) addLastOrder {
    NSArray *arr = _type == SPOT? [LWCache instance].spotWatchLists : [LWCache instance].marginalWatchLists;
    int max = 0;
    for(LWWatchList *l in arr) {
        if(l.order > max) {
            max = l.order;
        }
    }
    _order = max + 1;
}

@end
