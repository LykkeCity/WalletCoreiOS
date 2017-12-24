//
//  NewDecodeBase64.h
//  MyBookReader
//
//  Created by Andrey Snetkov on 23.07.12.
//  Copyright (c) 2012 sandr77@list.ru. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewDecodeBase64 : NSObject
+ (NSData *)decodeBase64WithString:(NSString *)strBase64;
+ (NSString *)encodeBase64WithData:(NSData *)objData;
@end
