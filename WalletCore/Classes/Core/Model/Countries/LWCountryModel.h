//
//  LWCountryModel.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"


@interface LWCountryModel : LWJSONObject<NSCopying> {
    
}


#pragma mark - Properties

@property (copy, nonatomic) NSString *identity;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *prefix;
@property (copy, nonatomic) NSString *iso2;

@end
