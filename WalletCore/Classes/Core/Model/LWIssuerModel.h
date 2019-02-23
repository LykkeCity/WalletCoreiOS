//
//  LWIssuerModel.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 07/12/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;

@interface LWIssuerModel : NSObject

-(id) initWithDict:(NSDictionary *) dict;

@property (strong, nonatomic) NSString *identity;
@property (strong, nonatomic) UIImage *icon;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *iconUrl;

@end
