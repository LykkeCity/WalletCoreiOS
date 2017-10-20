//
//  LWLykkeWalletsData.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 27.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"
#import "LWLykkeData.h"


@interface LWLykkeWalletsData : LWJSONObject {
    
}

@property (readonly, nonatomic) LWLykkeData *lykkeData;
@property (readonly, nonatomic) NSArray     *bankCards;
@property (readonly, nonatomic) NSString    *multiSig;
@property (readonly, nonatomic) NSString    *coloredMultiSig;

@end
