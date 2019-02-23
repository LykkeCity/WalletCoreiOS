//
//  LWURLProtocol.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 08/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWURLProtocol.h"
#import "LWKeychainManager.h"
#import "LWCache.h"

@import UIKit;

@interface LWURLProtocol () <NSURLConnectionDelegate>
{
    NSMutableData *receivedData;
}
@property (nonatomic, strong) NSURLConnection *connection;
@end


@implementation LWURLProtocol


+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    static NSUInteger requestCount = 0;
    
    if(![LWCache instance].cashInVisaURL)
        return NO;
    
    if ([NSURLProtocol propertyForKey:@"MyURLProtocolHandledKey" inRequest:request] || [request.URL.absoluteString rangeOfString:[LWKeychainManager instance].address].location!=NSNotFound) {
        return NO;
    }

    NSString *urlString=request.URL.absoluteString;

    
    if([LWCache instance].cashInVisaSuccessURL && [[LWCache instance].cashInVisaSuccessURL isEqualToString:request.URL.absoluteString])
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CreditCardFoundSuccessURL" object:nil];
    else if([LWCache instance].cashInVisaFailURL && [[LWCache instance].cashInVisaFailURL isEqualToString:request.URL.absoluteString])
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CreditCardFoundFailURL" object:nil];

    
    
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:[LWCache instance].UrlsToFormatRegex
                                  options:NSRegularExpressionCaseInsensitive
                                  error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:urlString
                                                    options:0
                                                      range:NSMakeRange(0, [urlString length])];
    if (match) {
        NSRange range = [match range];
        if (range.location != NSNotFound)
        {
            return YES;
            
        }
    }
    
    return NO;

    
    
    
    
    
    
    
    NSString *host=[request.URL host];
    NSArray *arr=[host componentsSeparatedByString:@"."];
    if(arr.count<2)
        return NO;
    host=arr[arr.count-2];
    
    NSString *aggregatorHost=[[NSURL URLWithString:[LWCache instance].cashInVisaURL] host];
    arr=[aggregatorHost componentsSeparatedByString:@"."];
    if(arr.count<2)
        return NO;
    aggregatorHost=arr[arr.count-2];
    
    if([host isEqualToString:aggregatorHost]==NO)
        return NO;
    
    NSLog(@"Request #%u: URL = %@", requestCount++, request);


    
    if ([NSURLProtocol propertyForKey:@"MyURLProtocolHandledKey" inRequest:request] || [request.URL.absoluteString rangeOfString:[LWKeychainManager instance].address].location!=NSNotFound) {
        return NO;
    }
    
    if([request.URL.absoluteString isEqualToString:[LWCache instance].cashInVisaURL]==NO)
    {
        return NO;
    }
    
    
    NSString *ext=[[request.URL pathExtension] lowercaseString];
    NSArray *exts=@[@"jpg", @"png", @"gif", @"woff", @"svg", @"ttf"];
    
    for(NSString *s in exts)
        if([s isEqualToString:ext])
            return NO;
//    if([ext isEqualToString:@"jpg"] || [ext isEqualToString:@"png"] || [ext isEqualToString:@"gif"])
//        return NO;
    
    


    
    return YES;
}


+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading {
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:@"MyURLProtocolHandledKey" inRequest:newRequest];
    
    self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
    receivedData=[[NSMutableData alloc] init];
}


- (void)stopLoading {
    [self.connection cancel];
    self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
    
//    [self.client URLProtocol:self didLoadData:data];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [self requestServer];
//    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

-(void) requestServer
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSDictionary *params=@{@"Url":self.request.URL.absoluteString, @"ContentBase64":[receivedData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn]};
        NSMutableURLRequest *request=[self createRequestWithAPI:@"FormatCreditVouchersContent" httpMethod:@"POST" getParameters:nil postParameters:params];

        [NSURLProtocol setProperty:@YES forKey:@"MyURLProtocolHandledKey" inRequest:request];

        
            NSURLResponse *responce;
            NSError *error;
            NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&responce error:&error];
            NSDictionary *result;
        NSData *resData;
            if(data)
            {
                result=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if(result && [result[@"Result"] isKindOfClass:[NSNull class]]==NO && result[@"Result"][@"FormattedContentBase64"])
                resData=[[NSData alloc] initWithBase64EncodedString:result[@"Result"][@"FormattedContentBase64"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
            }
        if(!resData)
            resData=receivedData;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.client URLProtocol:self didLoadData:resData];
            [self.client URLProtocolDidFinishLoading:self];
        });
            
        

    
    });
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

    NSString *userAgent=[NSString stringWithFormat:@"DeviceType=%@", device];

    [request addValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    return request;
}





@end
