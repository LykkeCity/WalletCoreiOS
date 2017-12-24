//
//  LWPersonalDataModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 21.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPersonalDataModel.h"


@implementation LWPersonalDataModel


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    if([json isKindOfClass:[NSDictionary class]]==NO)
        return nil;
    self = [super initWithJSON:json];
    if (self) {
        _amount   = json[@"Amount"];
        _fullName = json[@"FullName"]==nil?@"":json[@"FullName"];
        _email    = json[@"Email"]==nil?@"":json[@"Email"];
        _phone    = json[@"Phone"]==nil?@"":json[@"Phone"];
        _country  = json[@"Country"]==nil?@"":json[@"Country"];
        _address  = json[@"Address"]==nil?@"":json[@"Address"];
        _city     = json[@"City"]==nil?@"":json[@"City"];
        _zip      = json[@"Zip"]==nil?@"":json[@"Zip"];
        _firstName=json[@"FirstName"]==nil?@"":json[@"FirstName"];
        _lastName=json[@"LastName"]==nil?@"":json[@"LastName"];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        
        if (! jsonData) {
            NSLog(@"Got an error: %@", error);
        } else {
            _jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        
    }
    return self;
}


#pragma mark - Utils

- (BOOL)isFullNameEmpty {
    BOOL const isFullNameEmpty = self.fullName == nil ||
                            [self.fullName isKindOfClass:[NSNull class]] ||
                            [self.fullName isEqualToString:@""];
    return isFullNameEmpty;
}

- (BOOL)isPhoneEmpty {
    BOOL const isPhoneEmpty = self.phone == nil ||
                            [self.phone isKindOfClass:[NSNull class]] ||
                            [self.phone isEqualToString:@""];
    return isPhoneEmpty;
}

@end
