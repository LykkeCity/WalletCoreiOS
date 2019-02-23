//
//  LWHistoryManager.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 10.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>


@class LWTransactionsModel;


@interface LWHistoryManager : NSObject {
    
}

+ (NSArray *)prepareLimitHistory:(NSArray *)operations;
+ (NSArray *)prepareHistory:(NSArray *)operations marginal:(NSArray *)marginal;
+ (NSArray *)sortKeys:(NSDictionary *)dictionary;

+ (NSArray *)historyForOrderId:(NSString *)orderId;

@end
