//
//  LWRecoveryPasswordModel.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 22/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWRecoveryPasswordModel : NSObject

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *hint;
@property (strong, nonatomic) NSString *smsCode;
@property (strong, nonatomic) NSString *pin;
@property (strong, nonatomic) NSString *securityMessage1;
@property (strong, nonatomic) NSString *signature1;
@property (strong, nonatomic) NSString *securityMessage2;
@property (strong, nonatomic) NSString *signature2;

@property (strong, nonatomic) NSString *phoneNumber;


@end
