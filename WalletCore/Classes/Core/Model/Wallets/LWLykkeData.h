//
//  LWLykkeData.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 27.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"


@interface LWLykkeData : LWJSONObject {
    
}

//@property (readonly, nonatomic) NSNumber *equity;
@property (readonly, nonatomic) NSArray  *wallets;

@end
