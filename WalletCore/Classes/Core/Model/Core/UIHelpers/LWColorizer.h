//
//  LWColorizer.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 02.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Macro.h"
#import "UIColor+Generic.h"


@interface LWColorizer : NSObject {
    
}

SINGLETON_DECLARE

@property (readonly, nonatomic) CAGradientLayer *gradientButton;

@end
