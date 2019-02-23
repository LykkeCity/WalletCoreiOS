//
//  LWColorizer.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 02.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWColorizer.h"


@implementation LWColorizer

SINGLETON_INIT_EMPTY


#pragma mark - Properties

- (CAGradientLayer *)gradientButton {
    UIColor *colorOne = [UIColor colorWithHexString:@"FF9100"];
    UIColor *colorTwo = [UIColor colorWithHexString:@"AB00FF"];
    
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.colors = colors;
    gradient.locations = locations;
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    
    return gradient;
}

@end
