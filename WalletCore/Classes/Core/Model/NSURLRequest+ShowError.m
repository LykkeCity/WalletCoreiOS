//
//  NSURLRequest+ShowError.m
//  LykkeWallet
//
//  Created by vsilux on 20/11/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "NSURLRequest+ShowError.h"
#import <objc/runtime.h>

static char const * const kShowErrorIfFailedKey = "showErrorIfFailedKey";

@implementation NSURLRequest (ShowError)

- (void)setShowErrorIfFailed:(BOOL)showErrorIfFailed {
  NSNumber *value = [NSNumber numberWithBool:showErrorIfFailed];
  objc_setAssociatedObject(self, kShowErrorIfFailedKey, value , OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)showErrorIfFailed {
  NSNumber *value = objc_getAssociatedObject(self, kShowErrorIfFailedKey);
  return value == nil ? YES : [value boolValue];
}

@end
