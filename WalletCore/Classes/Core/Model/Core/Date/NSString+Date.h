//
//  NSString+Date.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 11.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Date)

+ (NSDateFormatter *)dateFormatter;
- (NSDateFormatter *)dateFormatter;

- (NSDate *)toDate;

- (NSDate *)toDateWithMilliSeconds;

@end
