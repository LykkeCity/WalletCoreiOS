//
//  LWNewsElementModel.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 30/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWNewsElementModel : NSObject


-(id) initWithDictionary:(NSDictionary *) dict;

@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSURL *imageURL;

@property (strong, nonatomic) NSURL *detailsURL;

@end
