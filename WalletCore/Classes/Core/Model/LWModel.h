//
//  LWModel.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 17/01/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWModel : NSObject

-(id) removeNulls:(id)dict;
-(NSDate *) dateFromString:(NSString *) string;

@end
