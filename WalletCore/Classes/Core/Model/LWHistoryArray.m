//
//  LWHistoryArray.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 18/01/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWHistoryArray.h"
#import "LWMWHistoryElement.h"

@interface LWHistoryArray()
{
    BOOL flagSorted;
    
    NSMutableArray *array;
    NSMutableArray *sortedContainers;
}

@end

@implementation LWHistoryArray

-(id) init
{
    self = [super init];
    array = [[NSMutableArray alloc] init];
    flagSorted = false;
    
    return self;
}

-(NSUInteger) count
{
    if(flagSorted == false) {
        [self sort];
    }
    return sortedContainers.count;
}

-(void) addObject:(id)anObject {
    [array addObject:anObject];
    flagSorted = false;
}

-(void) addObjectsFromArray:(NSArray *)otherArray
{
    [array addObjectsFromArray:otherArray];
    flagSorted = false;
}

-(id) objectAtIndex:(NSUInteger)index
{
    if(flagSorted == false) {
        [self sort];
    }
    return sortedContainers[index];
}

-(void) sort {
    NSArray *sorted = [array sortedArrayUsingComparator:^NSComparisonResult(LWMWHistoryElement *obj1, LWMWHistoryElement *obj2) {
        return [obj2.dateTime compare:obj1.dateTime];
    }];
    sortedContainers = [[NSMutableArray alloc] init];
    LWMWHistoryElement *prev;
    NSMutableArray *aaa;
    for(LWMWHistoryElement *el in sorted) {
        
        if(prev == nil || ((prev.type == OPEN || prev.type == CLOSE) != (el.type == OPEN || el.type == CLOSE))) {
            if(aaa) {
                [sortedContainers addObject:aaa];
            }
            aaa = [[NSMutableArray alloc] init];
        }
        [aaa addObject:el];
        prev = el;
    }
    if(aaa) {
        [sortedContainers addObject:aaa];
    }
    flagSorted = true;
}


@end
