//
//  LWLocalizationManager.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 24/05/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWLocalizationManager.h"
#import "LWKeychainManager.h"

@import UIKit;

@interface LWLocalizationManager()
{
    NSDictionary *translation;
    NSNumber *isFinishedLoading;
}

@end

@implementation LWLocalizationManager

+ (instancetype)shared
{
    static LWLocalizationManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[LWLocalizationManager alloc] init];
    });
    return shared;
}

-(void) downloadLocalization {
    
//    isFinishedLoading = @(YES);
//    return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
//        NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
//        NSLog(@"%@", language);
//        language = @"th";
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:[[NSBundle mainBundle] pathForResource:@"EnglishLocale.txt" ofType:nil]];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"%@", string);
        string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSArray *components = [string componentsSeparatedByString:@";"];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for(NSString *s in components) {
            [arr addObject:[s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        NSMutableDictionary *pairs = [[NSMutableDictionary alloc] init];
        
        for(NSString *s in arr) {
            NSArray *comps = [s componentsSeparatedByString:@"="];
            if(comps.count != 2) {
                continue;
            }
            pairs[[comps[0] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \""]]] = [comps[1] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \""]];
        }
        
 //       NSLog(@"%@", pairs);
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"Language":language, @"Translations": pairs} options:0 error:nil];
        
        
//        NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        NSLog(@"%@", str);
        
        
        NSString *address=[NSString stringWithFormat:@"https://%@/api/%@",[LWKeychainManager instance].address,@"Translations"];
        
        
        NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:address]];
        [request setHTTPMethod:@"POST"];
        
            [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            
            
        
            
            request.HTTPBody = jsonData;
            
        
        NSString *token = [LWKeychainManager instance].token;
        
        
        if (token)
        {
            [request addValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
        }
        
        NSString *device;
        if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
            device=@"iPhone";
        else
            device=@"iPad";
#ifdef TEST
        NSString *userAgent=[NSString stringWithFormat:@"DeviceType=%@;AppVersion=234.0", device];
#else
        NSString *userAgent=[NSString stringWithFormat:@"DeviceType=%@;AppVersion=%@", device, [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
#endif
        [request addValue:userAgent forHTTPHeaderField:@"User-Agent"];
        
        NSURLResponse *response;
        NSError *error;
        NSData *translationData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSHTTPURLResponse *rrr = response;
        NSLog(@"%d", rrr.statusCode);
        if(!translationData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                isFinishedLoading = @(YES);
            });
            return;
        }
        translation = [NSJSONSerialization JSONObjectWithData:translationData options:0 error:nil][@"Translations"];
        
//        NSLog(@"%@", translation[@"Translations"][@"tab.trading"]);
//        NSLog(@"%@", translation);
        dispatch_async(dispatch_get_main_queue(), ^{
            isFinishedLoading = @(YES);
        });
        
    });
    
    
}

-(BOOL) isLocalizationLoaded {
    return isFinishedLoading.boolValue;
}

-(NSString *) localize:(NSString *) string {
    if(!translation) {
        return NSLocalizedString(string, string);
    }
    else {
        NSString *str = translation[string];
        if(str) {
            return str;
        }
    }
    return NSLocalizedString(string, string);
}


@end
