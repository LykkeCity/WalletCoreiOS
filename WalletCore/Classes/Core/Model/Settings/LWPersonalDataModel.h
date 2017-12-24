//
//  LWPersonalDataModel.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 21.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"


@interface LWPersonalDataModel : LWJSONObject {
    
}


#pragma mark - Properties

@property (readonly, nonatomic) NSNumber *amount;
@property (readonly, nonatomic) NSString *fullName;
@property (readonly, nonatomic) NSString *email;
@property (readonly, nonatomic) NSString *phone;
@property (readonly, nonatomic) NSString *country;
@property (readonly, nonatomic) NSString *zip;
@property (readonly, nonatomic) NSString *city;
@property (readonly, nonatomic) NSString *address;

@property (readonly, nonatomic) NSString *firstName;
@property (readonly, nonatomic) NSString *lastName;

@property (readonly, nonatomic) NSString *jsonString;


#pragma mark - Utils

- (BOOL)isFullNameEmpty;
- (BOOL)isPhoneEmpty;

@end
