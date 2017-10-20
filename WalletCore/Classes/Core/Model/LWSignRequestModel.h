//
//  LWSignRequestModel.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 05/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWSignRequestModel : NSObject

-(id) initWithDictionary:(NSDictionary *) dict;

@property (strong, nonatomic) NSString *blockchain;
@property (strong, nonatomic) NSString *hashString;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *requestId;

@property (strong, nonatomic) NSString *signature;

@end
