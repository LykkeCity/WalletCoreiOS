//
//  LWValidator.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 10.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIButton.h>


@interface LWValidator : NSObject {
    
}

#pragma mark - Texts

+ (BOOL)validateEmail:(NSString *)input;
+ (BOOL)validateFullName:(NSString *)input;
+ (BOOL)validatePhone:(NSString *)input;
+ (BOOL)validatePassword:(NSString *)input;
+ (BOOL)validateConfirmPassword:(NSString *)input;
+ (BOOL)validateCardNumber:(NSString *)input;
+ (BOOL)validateCardExpiration:(NSString *)input;
+ (BOOL)validateCardOwner:(NSString *)input;
+ (BOOL)validateCardCode:(NSString *)input;
+ (BOOL)validateQrCode:(NSString *)input;

+ (void)setButton:(UIButton *)button enabled:(BOOL)isValid;
+ (void)setPriceButton:(UIButton *)button enabled:(BOOL)isValid;
+ (void)setSellButton:(UIButton *)button enabled:(BOOL)enabled;
+ (void)setBuyButton:(UIButton *)button enabled:(BOOL)enabled;
+(void) setButtonWithClearBackground:(UIButton *) button enabled:(BOOL) enabled;

@end
