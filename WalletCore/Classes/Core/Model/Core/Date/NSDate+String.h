//
//  NSDate+String.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 11.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (String)

- (NSString *)toShortFormat;

-(NSString *) timePassedFromDate:(NSDate *) date;

@end
