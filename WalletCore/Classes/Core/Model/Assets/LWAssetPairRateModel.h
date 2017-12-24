//
//  LWAssetPairRateModel.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 04.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"


@interface LWAssetPairRateModel : LWJSONObject {
    
}

-(void) invert;

#pragma mark - Properties

@property (readonly, nonatomic) NSString *identity;
@property (readonly, nonatomic) NSNumber *bid;
@property (readonly, nonatomic) NSNumber *ask;
@property (readonly, nonatomic) NSNumber *pchng;
@property (readonly, nonatomic) NSNumber *expTimeout;
@property (readonly, nonatomic) NSArray  *lastChanges;
@property BOOL inverted;

    @property BOOL askIsRaising;
    @property BOOL bidIsRaising;
    
    
@end
