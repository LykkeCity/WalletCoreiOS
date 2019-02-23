//
//  LWStringUtils.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 04.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LWStringUtils : NSObject {

}

+ (NSString *)formatCreditCard:(NSString *)input;
+ (NSString *)formatCreditCardExpiry:(NSString *)input shouldRemoveText:(BOOL)shouldRemoveText;
+ (NSString *)trimSpecialCharacters:(NSString *)input;
+ (NSNumber *)monthFromExpiration:(NSString *)input;
+ (NSNumber *)yearFromExpiration:(NSString *)input;

@end
