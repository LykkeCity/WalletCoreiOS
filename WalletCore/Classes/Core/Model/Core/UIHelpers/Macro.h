//
//  Macro.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 02.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#ifndef Macro_h
#define Macro_h

//#define Localize(tag) NSLocalizedString(tag, tag)
#define AppDlg ((AppDelegate *)[UIApplication sharedApplication].delegate)

#define SINGLETON_DECLARE + (instancetype)instance;
#define SINGLETON_INIT \
    - (instancetype)init { NSAssert(0, @"Use 'instance' instead."); return nil; } \
	static id instance = nil; \
	static dispatch_once_t onceToken; \
    + (instancetype)instance { \
        dispatch_once(&onceToken, ^{ \
            instance = [[self.class alloc] initPrivate]; \
        }); \
        return instance; \
    } \
	+ (void)reset { \
		instance = nil; \
		onceToken = 0; \
		[self instance]; \
	} \
    - (instancetype)initPrivate
#define SINGLETON_INIT_EMPTY SINGLETON_INIT { return [super init]; }


extern NSString * Localize(NSString *tag);
extern NSString * NSStringFromClassWithoutModule(Class obj);

#endif /* Macro_h */
