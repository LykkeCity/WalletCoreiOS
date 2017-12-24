//
//  LWTransactionsModel.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 10.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"


@interface LWTransactionsModel : LWJSONObject {
    
}

@property (readonly, nonatomic) NSArray *trades;
@property (readonly, nonatomic) NSArray *cashInOut;


@property (readonly, nonatomic) NSArray *transfers;


@end
