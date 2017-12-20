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
#import "NSURLRequest+ShowError.h"
#import <WalletCore/WalletCore-Swift.h>

@implementation LWNetworkTemplate

#pragma mark HELPERS

- (void)sendRequest:(NSURLRequest *)request completion:(void(^)(NSDictionary *response))completion {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSDictionary *response = [self sendRequest:request];
    if (completion) {
      dispatch_async(dispatch_get_main_queue(), ^{
        completion(response);
      });
    }
  });
}

- (id)sendRequest:(NSURLRequest *)request {
  NSURLResponse *responce;
  NSError *error;
  NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&responce error:&error];
  NSDictionary *result;
  if (data && data.length) {
    result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    NSDictionary *resultData = result[@"Result"];
    NSDictionary *resultError = result[@"Error"];
    
    if (resultError && [[resultError class] isSubclassOfClass:[NSNull class]] == NO) {
      int errorCode = [resultError[@"Code"] intValue];
      NSString *errorMessage = resultError[@"Message"];
      
      // REQUEST_ERROR_SHOULD_PROCESS_OFFCHAIN_REQUEST: need to call offchain/requests
      // REQUEST_ERROR_NO_DATA: duplicated request of offchain/requestTransfer (do nothing)
      // REQUEST_ERROR_NO_OFFCHAIN_LIQUIDITY: (Not enough money on ME to create channel) need to skip this request and continue with next
      BOOL isOffchainError = [@[@(REQUEST_ERROR_SHOULD_PROCESS_OFFCHAIN_REQUEST),
                                @(REQUEST_ERROR_NO_DATA),
                                @(REQUEST_ERROR_NO_OFFCHAIN_LIQUIDITY)]
                              containsObject:@(errorCode)];
      
      BOOL isBackupError = [@[@(REQUEST_ERROR_BACKUP_WARNING),
                              @(REQUEST_ERROR_BACKUP_REQUIRED)]
                            containsObject:@(errorCode)];
      
      BOOL isKycError = [@[@(REQUEST_ERROR_INCONSISTENT_DATA)]
                         containsObject:@(errorCode)];
      
      if (isBackupError) {
        [self showBackupView:errorCode == REQUEST_ERROR_BACKUP_WARNING message:errorMessage];
      }
      
      if (isKycError) {
        [self showKycView];
      }
      
      NSMutableDictionary *userInfo = @{}.mutableCopy;
      if (errorMessage) {
        userInfo[@"Message"] = errorMessage;
      }
      error = [NSError errorWithDomain:[request.URL absoluteString] code:errorCode userInfo:userInfo];
      
      if ((isOffchainError && ([self showOffchainErrors] || (errorCode == REQUEST_ERROR_NO_OFFCHAIN_LIQUIDITY && self.shouldShowOffchainLiquidityError))) ||
          (isKycError && [self showKycErrors]) ||
          (!isOffchainError && !isKycError && !isBackupError)) {
        [self showReleaseError:error request:request];
      }
    } else if ([result isKindOfClass:[NSDictionary class]] == NO) {
      [self showReleaseError:nil request:request];
      error = [NSError errorWithDomain:[request.URL absoluteString] code:500 userInfo:nil];
      
      return error;
    }
    
    if (result && resultData && [resultData isKindOfClass:[NSNull class]] == NO) {
      if ([resultData isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *checkedResult = [resultData mutableCopy];
        [self checkResult:checkedResult];
        return checkedResult;
      } else if ([resultData isKindOfClass:[NSArray class]]) {
        return [self checkArrayResult:(NSArray *)resultData];
      }
      return resultData;
    }
  } else {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) responce;
    if ([httpResponse statusCode] == 204) {
      return result;
    }
    
    [self showReleaseError:error request:request];
  }
  
  return error;
}

- (NSMutableURLRequest *)createRequestWithAPI:(NSString *)apiMethod
                            httpMethod:(NSString *)httpMethod
                         getParameters:(NSDictionary *)getParams
                        postParameters:(NSDictionary *)postParams {
  
  NSString *address = [NSString stringWithFormat:@"%@%@", [self baseURLPath], apiMethod];
  if (getParams) {
    NSArray *keys =[getParams allKeys];
    address = [address stringByAppendingString:@"?"];
    NSMutableArray *pairs = [NSMutableArray new];
    for (NSString *key in keys) {
      [pairs addObject:[[NSString stringWithFormat:@"%@=%@", key, getParams[key]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    address = [address stringByAppendingString:[pairs componentsJoinedByString:@"&"]];
  }
  
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:address]];
  [request setHTTPMethod:httpMethod];
  
  if(postParams) {
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:postParams options:0 error:nil];
    
    request.HTTPBody = jsonData;
  }
  
  NSString *token = [LWKeychainManager instance].token;
  
  if (token) {
    [request addValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
  }
  
  NSString *device = DeviceType.IS_IPHONE ? @"iPhone" : @"iPad";
  NSString *userAgent=[NSString stringWithFormat:@"DeviceType=%@;AppVersion=%@", device, [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
  [request addValue:userAgent forHTTPHeaderField:@"User-Agent"];
  
  return request;
}

- (NSMutableURLRequest *)getRequestWithAPI:(NSString *)apiMethod params:(NSDictionary *)params {
  return [self createRequestWithAPI:apiMethod httpMethod:kMethodGET getParameters:params postParameters:nil];
}

- (NSMutableURLRequest *)postRequestWithAPI:(NSString *)apiMethod params:(NSDictionary *)params {
  return [self createRequestWithAPI:apiMethod httpMethod:kMethodPOST getParameters:nil postParameters:params];
}

- (NSString *)percentEscapeString:(NSString *)string {
  NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                               (CFStringRef)string,
                                                                               (CFStringRef)@" ",
                                                                               (CFStringRef)@":/?@!$&'()*+,;=",
                                                                               kCFStringEncodingUTF8));
  return [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}


-(NSArray *) checkArrayResult:(NSArray *) resArray {
  NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
  dict[@"array"] = resArray;
  [self checkResult:dict];
  return dict[@"array"];
}

-(void) checkResult:(NSMutableDictionary *) resultDict {
  NSArray *keys = [resultDict allKeys];
  for(NSString *k in keys) {
    id object = resultDict[k];
    if([object isKindOfClass:[NSNull class]]) {
      [resultDict removeObjectForKey:k];
    }
    if([object isKindOfClass:[NSDictionary class]]) {
      NSMutableDictionary *newDict = [object mutableCopy];
      [self checkResult:newDict];
      resultDict[k] = newDict;
    }
    if([object isKindOfClass:[NSArray class]]) {
      NSMutableArray *newArr = [object mutableCopy];
      for(int i = 0; i < [newArr count]; i++) {
        id arrElement = newArr[i];
        if([arrElement isKindOfClass:[NSNull class]]) {
          [newArr removeObjectAtIndex:i];
          i--;
        } else if([arrElement isKindOfClass:[NSDictionary class]]){
          NSMutableDictionary *newDict = [arrElement mutableCopy];
          [self checkResult:newDict];
          [newArr replaceObjectAtIndex:i withObject:newDict];
        }
      }
      resultDict[k] = newArr;
    }
  }
}

- (void)showReleaseError:(NSError *)error request:(NSURLRequest *)request {
    assert("Implement this method as extenstion in your project!!!");
//  if (![request showErrorIfFailed]) {
//    return;
//  }
//
//  dispatch_async(dispatch_get_main_queue(), ^{
//
//    if (error.code == NSURLErrorUserCancelledAuthentication) {
//      AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//      [appDelegate.mainController logout];
//      return;
//    }
//
//    NSString *message = error.userInfo[@"Message"];
//    if (!message) {
//      message = [error localizedDescription];
//    }
//    if (!message) {
//      message = @"Unknown server error";
//    }
//
//    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//
//    for (UIView *subview in window.subviews) {
//      if ([subview isKindOfClass:[LWErrorView class]]) {
//        return;
//      }
//    }
//
//    NSDateFormatter *formatter = [NSDateFormatter new];
//    formatter.dateStyle = NSDateFormatterLongStyle;
//    formatter.timeStyle = NSDateFormatterShortStyle;
//    message = [message stringByAppendingFormat:@"\n\n%@", [formatter stringFromDate:[NSDate date]]];
//
//    LWErrorView *errorView = [LWErrorView modalViewWithDescription:message];
//    [errorView setFrame:window.bounds];
//
//    CATransition *transition = [CATransition animation];
//    transition.duration = 0.5;
//    transition.type = kCATransitionPush;
//    transition.subtype = kCATransitionFromTop;
//    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//    [errorView.layer addAnimation:transition forKey:nil];
//
//    [window addSubview:errorView];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//      [UIView setAnimationsEnabled:true];
//    });
//  });
}

- (void)showBackupView:(BOOL)isOptional message:(NSString *)message {
    assert("Implement this method as extenstion in your project!!!");
//  dispatch_async(dispatch_get_main_queue(), ^{
//    LWBackupNotificationView *view = [LWBackupNotificationView createView];
//    view.type = isOptional ? BackupRequestTypeOptional : BackupRequestTypeRequired;
//    view.text = message;
//    [view show];
//  });
}

- (void)showKycView {
    assert("Implement this method as extenstion in your project!!!");
//  [[LWKYCManager sharedInstance] manageKYCStatus];
}

- (BOOL)showOffchainErrors {
  return NO;
}

- (NSString *)baseURLPath {
  return [NSString stringWithFormat:@"https://%@/api/", [LWKeychainManager instance].address];
}

- (BOOL)showKycErrors {
  return YES;
}

@end
