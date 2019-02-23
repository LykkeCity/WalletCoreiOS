//
//  LWImageDownloader.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 24/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;

@interface LWImageDownloader : NSObject

+ (instancetype)shared;
-(void) downloadImageFromURLString:(NSString *) urlString shouldAuthenticate:(BOOL) flagNeedAuthentication withCompletion:(void(^)(UIImage *)) completion;

-(void) logout;

@end
