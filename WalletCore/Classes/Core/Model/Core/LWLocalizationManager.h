//
//  LWLocalizationManager.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 24/05/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWLocalizationManager : NSObject


+ (instancetype)shared;
-(void) downloadLocalization;
-(NSString *) localize:(NSString *) string;
-(BOOL) isLocalizationLoaded;
@end
