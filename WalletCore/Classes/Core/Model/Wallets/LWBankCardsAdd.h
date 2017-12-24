//
//  LWBankCardsAdd.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 31.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LWBankCardsAdd : NSObject {
    
}

@property (copy, nonatomic) NSString *bankNumber;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSNumber *monthTo;
@property (copy, nonatomic) NSNumber *yearTo;
@property (copy, nonatomic) NSString *cvc;

@end
