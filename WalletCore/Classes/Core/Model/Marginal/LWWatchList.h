//
//  LWWatchList.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 27/12/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LWWatchListType) {
  LWWatchListTypeCFD,
  LWWatchListTypeSPOT
};

@class LWWatchListElement;

@interface LWWatchList : NSObject

- (instancetype)initWithDict:(NSDictionary *)dict type:(LWWatchListType)type;
- (void)updateWithDict:(NSDictionary *)dict;

- (void)addLastOrder;

@property (assign, nonatomic) LWWatchListType type;

@property (strong, nonatomic) NSString *accountId;
@property (strong, nonatomic) NSString *identity;
@property (strong, nonatomic) NSString *name;
@property (readonly, nonatomic) NSMutableArray *elements;
@property (readonly, nonatomic) BOOL readOnly;
@property (assign, nonatomic, getter = isSelected) BOOL selected;
@property (readonly, assign, nonatomic) BOOL isDefault;

@property (assign, nonatomic) NSInteger order;


-(void)addElement:(LWWatchListElement *) element;
-(void)removeElement:(LWWatchListElement *) element;

-(NSDictionary *)dictionary;
-(LWWatchList *)copy;

@end
