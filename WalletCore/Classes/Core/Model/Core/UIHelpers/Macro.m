//
//  Macro.c
//  LykkeWallet
//
//  Created by Andrey Snetkov on 02/04/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LWLocalizationManager.h"

NSString * Localize(NSString *tag) {
    return [[LWLocalizationManager shared] localize:tag];
    
//    return NSLocalizedString(tag, tag);
}


