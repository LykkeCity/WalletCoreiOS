//
//  LWWatchList.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 27/12/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {CFD, SPOT} WATCH_LIST_TYPE;

@class LWWatchListElement;

@interface LWWatchList : NSObject

-(id) initWithDict:(NSDictionary *) dict type:(WATCH_LIST_TYPE) type;
-(void) updateWithDict:(NSDictionary *) dict;

-(void) addLastOrder;

@property WATCH_LIST_TYPE type;

@property (strong, nonatomic) NSString *accountId;
@property (strong, nonatomic) NSString *identity;
@property (strong, nonatomic) NSString *name;
@property (readonly, nonatomic) NSMutableArray *elements;
@property BOOL readOnly;
@property BOOL isSelected;

@property int order;


-(void) addElement:(LWWatchListElement *) element;
-(void) removeElement:(LWWatchListElement *) element;

-(NSDictionary *) dictionary;
-(LWWatchList *) copy;

@end
