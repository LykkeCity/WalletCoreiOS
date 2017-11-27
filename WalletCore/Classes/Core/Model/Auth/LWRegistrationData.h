//
//  LWRegistrationData.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 11.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface LWRegistrationData : NSObject<NSCopying> {
    
}

@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *fullName;
@property (copy, nonatomic) NSString *phone;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *clientInfo;

@property (copy, nonatomic) NSString *passwordHint;

@property (copy, nonatomic, nullable) NSString *partnerIdentifier;

@end

NS_ASSUME_NONNULL_END
