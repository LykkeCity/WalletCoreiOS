//
//  LWNetworkTemplate.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 07/04/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWNetworkTemplate.h"
#import "LWPrivateKeyManager.h"
#import "LWKeychainManager.h"


@implementation LWNetworkTemplate

#pragma mark HELPERS


-(id) sendRequest:(NSURLRequest *) request
{
    NSURLResponse *responce;
    NSError *error;
    NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&responce error:&error];
    NSDictionary *result;
    if(data && data.length)
    {
        
        result=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        if(result[@"Error"] && [[result[@"Error"] class] isSubclassOfClass:[NSNull class]]==NO)
        {
            
            if([result[@"Error"][@"Code"] intValue]==9 || [result[@"Error"][@"Code"] intValue]==10)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    LWBackupNotificationView *view = [[[NSBundle mainBundle] loadNibNamed:@"LWBackupNotificationView" owner:self options:nil] objectAtIndex:0];
//                    if([result[@"Error"][@"Code"] intValue]==9)
//                        view.type=BackupRequestTypeOptional;
//                    else
//                        view.type=BackupRequestTypeRequired;
//                    view.text=result[@"Error"][@"Message"];
//                    [view show];
                    });
                return nil;
            }

            
            NSMutableDictionary *userInfo=[[NSMutableDictionary alloc] init];
            if(result[@"Error"][@"Message"])
                userInfo[@"Message"]=result[@"Error"][@"Message"];
            int code = [result[@"Error"][@"Code"] intValue];
            error=[NSError errorWithDomain:[request.URL absoluteString]  code:code userInfo:userInfo];
            if(code != 15 && code != 12 && code != 16) //15-need to call offchain/requests,  12-duplicated request of offchain/requestTransfer (do nothing)
                                                       // 16 - (Not enough money on ME to create channel) need to skip this request and continue with next
                [self showReleaseError:error];
            
        }
        else if([result isKindOfClass:[NSDictionary class]]==NO)
        {
            [self showReleaseError:nil];
            error=[NSError errorWithDomain:[request.URL absoluteString] code:500 userInfo:nil];
            
            return error;
        }
        if(result && result[@"Result"] && [result[@"Result"] isKindOfClass:[NSNull class]]==NO)
        {
            result=result[@"Result"];
            if([result isKindOfClass:[NSDictionary class]])
            {
                NSMutableDictionary *checkedResult=[result mutableCopy];
                [self checkResult:checkedResult];
                result=checkedResult;
            }
            else if([result isKindOfClass:[NSArray class]])
            {
                result=[self checkArrayResult:result];
            }
            
            return result;
        }
        
        
    }
    else
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) responce;
        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
//        dispatch_async(dispatch_get_main_queue(), ^{ //Testing
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:request.URL.absoluteString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alert show];
//            });
        [self showReleaseError:error];
    }
    
    return error;
}


-(NSMutableURLRequest *) createRequestWithAPI:(NSString *) apiMethod httpMethod:(NSString *) httpMethod getParameters:(NSDictionary *) getParams postParameters:(NSDictionary *) postParams
{
    
    NSString *address=[NSString stringWithFormat:@"https://%@/api/%@",[LWKeychainManager instance].address,apiMethod];
    if(getParams)
    {
        NSArray *keys=[getParams allKeys];
        address=[address stringByAppendingString:@"?"];
        for(NSString *key in keys)
            address=[address stringByAppendingFormat:@"&%@=%@",key, getParams[key]];
    }
    
    
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:address]];
    [request setHTTPMethod:httpMethod];
    
    if(postParams)
    {
        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:postParams options:0 error:nil];
        
        request.HTTPBody = jsonData;
        
        //        NSMutableArray *parameterArray = [NSMutableArray array];
        //
        //        [postParams enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        //            NSString *param = [NSString stringWithFormat:@"%@=%@", key, [self percentEscapeString:obj]];
        //            [parameterArray addObject:param];
        //        }];
        //
        //        NSString *string = [parameterArray componentsJoinedByString:@"&"];
        //        [request setHTTPBody:[string dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
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
    NSString *userAgent=[NSString stringWithFormat:@"DeviceType=%@;AppVersion=%@;ClientFeatures=1", device, [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    [request addValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    return request;
}

- (NSString *)percentEscapeString:(NSString *)string
{
    NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (CFStringRef)string,
                                                                                 (CFStringRef)@" ",
                                                                                 (CFStringRef)@":/?@!$&'()*+,;=",
                                                                                 kCFStringEncodingUTF8));
    return [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}


-(NSArray *) checkArrayResult:(NSArray *) resArray
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    dict[@"array"]=resArray;
    [self checkResult:dict];
    return dict[@"array"];
}

-(void) checkResult:(NSMutableDictionary *) resultDict
{
    NSArray *keys=[resultDict allKeys];
    for(NSString *k in keys)
    {
        id object=resultDict[k];
        if([object isKindOfClass:[NSNull class]])
        {
            [resultDict removeObjectForKey:k];
        }
        if([object isKindOfClass:[NSDictionary class]])
        {
            NSMutableDictionary *newDict=[object mutableCopy];
            [self checkResult:newDict];
            resultDict[k]=newDict;
        }
        if([object isKindOfClass:[NSArray class]])
        {
            NSMutableArray *newArr=[object mutableCopy];
            for(int i=0;i<[newArr count];i++)
            {
                id arrElement=newArr[i];
                if([arrElement isKindOfClass:[NSNull class]])
                {
                    [newArr removeObjectAtIndex:i];
                    i--;
                }
                else if([arrElement isKindOfClass:[NSDictionary class]])
                {
                    NSMutableDictionary *newDict=[arrElement mutableCopy];
                    [self checkResult:newDict];
                    [newArr replaceObjectAtIndex:i withObject:newDict];
                    
                }
                
            }
            resultDict[k]=newArr;
        }
    }
}


- (void)showReleaseError:(NSError *) error {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(error.code == NSURLErrorUserCancelledAuthentication) {
//            AppDelegate *tmptmp = [UIApplication sharedApplication].delegate;
//            [tmptmp.mainController logout];
            return;
        }
        
        NSString *message=error.userInfo[@"Message"];
        if(!message)
            message=[error localizedDescription];
        if(!message)
            message=@"Unknown server error";
        UIWindow *window=[[UIApplication sharedApplication] keyWindow];
        
        
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterLongStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
        message = [message stringByAppendingFormat:@"\n\n%@", [formatter stringFromDate:[NSDate date]]];
        
        // animation
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5;
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromTop;
        [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//        [errorView.layer addAnimation:transition forKey:nil];
        
        // showing modal view
//        [window addSubview:errorView];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView setAnimationsEnabled:true];
        });
        
    });
}


@end
