//
//  LWSwiftCredentialsModel.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 07/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWSwiftCredentialsModel : NSObject

@property (strong, nonatomic) NSString *bic;
@property (strong, nonatomic) NSString *accountNumber;
@property (strong, nonatomic) NSString *accountName;
@property (strong, nonatomic) NSString *purposeOfPayment;
@property (strong, nonatomic) NSString *bankAddress;
@property (strong, nonatomic) NSString *correspondentBank;
@property (strong, nonatomic) NSString *companyAddress;


@end
