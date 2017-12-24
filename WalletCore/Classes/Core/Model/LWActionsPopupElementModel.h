//
//  LWActionsPopupElementModel.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 29/04/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

@interface LWActionsPopupElementModel : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UIImage *icon;
@property (strong, nonatomic) NSString *iconUrl;
@property (strong, nonatomic) void (^action)(void);

@end
