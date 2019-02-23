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
#import "LWUserDefault.h"

static NSString *kDefaultWatchListName = @"All assets";

@interface LWWatchList ()
{
    NSMutableArray *elements;
}
@end

@implementation LWWatchList


- (instancetype)init {
  self = [super init];
  if (self) {
    self.name = @"";
    elements = [[NSMutableArray alloc] init];
    self.order = 0;
  }
  return self;
}

- (instancetype)initWithDict:(NSDictionary *)dict type:(LWWatchListType)type {
  self = [super init];
  if (self) {
    self.type = type;
    [self updateWithDict:dict];
  }
  return self;
}

- (void)updateWithDict:(NSDictionary *)dict {
  self.name = dict[@"Name"];
  
  NSMutableArray *arr=[[NSMutableArray alloc] init];
  if (self.type == LWWatchListTypeCFD) {
    NSArray *assets=[LWMarginalWalletsDataManager shared].assets;
    for (NSString *s in dict[@"AssetIds"]) {
      for (LWMarginalWalletAsset *asset in assets) {
        if ([asset.identity isEqualToString:s]) {
          LWWatchListElement *element=[[LWWatchListElement alloc] initWithMarginalAsset:asset];
          [arr addObject:element];
          break;
        }
      }
    }
    self.accountId = dict[@"AccountId"];
  } else {
    NSArray *assets = [LWCache instance].allAssetPairs;
    for (NSString *s in dict[@"AssetIds"]) {
      for (LWAssetPairModel *asset in assets) {
        if ([asset.identity isEqualToString:s]) {
          LWWatchListElement *element=[[LWWatchListElement alloc] initWithSpotAssetPair:asset];
          [arr addObject:element];
          break;
        }
      }
    }
  }
  
  self.order = [dict[@"Order"] intValue];
  elements = arr;
  self.identity = dict[@"Id"];
  
  _readOnly = [dict[@"ReadOnly"] boolValue];
}

- (void)setSelected:(BOOL)selected {
    if (!_identity) {
        return;
    }
	
	if (!selected) {
		return;
	}
	
	if (self.type == LWWatchListTypeCFD) {
		[LWUserDefault instance].selectedCFDWatchListId = self.identity;
	} else {
		[LWUserDefault instance].selectedSPOTWatchListId = self.identity;
	}
}

- (BOOL)isSelected {
    if (self.type == LWWatchListTypeCFD) {
        return [[LWUserDefault instance].selectedCFDWatchListId isEqualToString:_identity];
    }
    return [[LWUserDefault instance].selectedSPOTWatchListId isEqualToString:_identity];
}

- (NSDictionary *)dictionary {
  NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
  dict[@"Name"] = _name;
  NSMutableArray *assetIds = [[NSMutableArray alloc] init];
  for (LWWatchListElement *asset in elements) {
    [assetIds addObject:asset.assetId];
  }
  
  dict[@"AssetIds"] = assetIds;
  
  if (self.type == LWWatchListTypeCFD) {
    dict[@"AccountId"] = _accountId;
  }
  
  if (self.identity != nil) {
    dict[@"Id"] = self.identity;
  }
  
  dict[@"Order"] = @(self.order);
  
  return dict;
}

- (NSString *)name {
	if ([self isDefault]) {
		return Localize(@"watchlists.selected.all");
	}
	return _name;
}

- (BOOL)isDefault {
	return [_name isEqualToString:kDefaultWatchListName];
}

- (NSMutableArray *)elements {
  if (self.type == LWWatchListTypeCFD) {
    NSMutableArray *filteredElements = [[NSMutableArray alloc] init];
    LWMarginalAccount *account = [LWMarginalWalletsDataManager shared].currentAccount;
    for (LWWatchListElement *a in elements) {
      if ([(LWMarginalWalletAsset *)a.asset account] == account) {
        [filteredElements addObject:a];
      }
    }
    return filteredElements;
  } else {
    return elements;
  }
}

- (instancetype)copy {
  LWWatchList *newWatchList = [[LWWatchList alloc] init];
  newWatchList.accountId = _accountId;
  for(LWWatchListElement *e in elements) {
    [newWatchList addElement:e];
  }
  
  newWatchList->_readOnly = NO;
  newWatchList.selected = NO;
  newWatchList.order = 0;
  newWatchList->_type = _type;
  
  return newWatchList;
}

- (void)addElement:(LWWatchListElement *)element {
    [elements addObject:element];
}

- (void)removeElement:(LWWatchListElement *)element {
    [elements removeObject:element];
}


- (void)addLastOrder {
    NSArray *arr = self.type == LWWatchListTypeSPOT ? [LWCache instance].spotWatchLists : [LWCache instance].marginalWatchLists;
    NSInteger max = 0;
    for(LWWatchList *l in arr) {
        if(l.order > max) {
            max = l.order;
        }
    }
    _order = max + 1;
}

@end
