//
//  LWAssetCategoryModel.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 27/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

@interface LWAssetCategoryModel : NSObject

-(id) initWithDictionary:(NSDictionary *) dict;

@property (strong, nonatomic) NSString *iconUrl;
@property (strong, nonatomic) NSString *identity;
@property (strong, nonatomic) NSString *name;


@property (strong, nonatomic) UIImage *iconImage;

@property (strong, nonatomic) NSMutableArray *assets;

@end
