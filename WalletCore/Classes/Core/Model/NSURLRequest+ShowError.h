//
//  NSURLRequest+ShowError.h
//  LykkeWallet
//
//  Created by vsilux on 20/11/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (ShowError)

// Default is YES
@property (assign, nonatomic) BOOL showErrorIfFailed;

@end
