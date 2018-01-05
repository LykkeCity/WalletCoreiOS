//
//  LWPacket.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 02.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacket.h"
#import "LWKeychainManager.h"
#import "LWCache.h"


@implementation LWPacket


#pragma mark - GDXRESTPacket

- (instancetype)initWithJSON:(id)json {
    return [super init]; // our root packet will not parse any input JSON
}

- (NSDictionary*) getResut {
    return result;
}

- (void)parseResponse:(id)response error:(NSError *)error {
    result = [response objectForKey:@"Result"];
    _reject = response[@"Error"];
    
    
    if ([LWCache instance].debugMode) {
        if (_reject && ![_reject isKindOfClass:[NSNull class]]) {
            _reject = [response[@"Error"] mutableCopy];
            NSString *message = [_reject objectForKey:kErrorMessage];
            NSString *temp = [NSString stringWithFormat:@"%@%@ %@",
                              [self urlBase],
                              [self urlRelative],
                              message];
            [_reject setObject:temp forKey:kErrorMessage];
        }
    }
    if([result isKindOfClass:[NSNull class]])
    {
        result=nil;
    }
    else if([result isKindOfClass:[NSDictionary class]])
    {
        
        
        NSMutableDictionary *checkedResult=[result mutableCopy];
        [self checkResult:checkedResult];
        result=checkedResult;
    }
    else if([result isKindOfClass:[NSArray class]])
    {
        result=[self checkArrayResult:result];
    }
    
    _isRejected = (self.reject != nil) && ![self.reject isKindOfClass:NSNull.class];
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



- (NSString *)urlBase {
    NSString *address = [LWKeychainManager instance].address;
    NSString *addr = [NSString stringWithFormat:@"https://%@/api/", address];
    NSLog(@"%@", addr);//Andrey
    return addr;
}

- (NSString *)urlRelative {
    NSAssert(0, nil); // root packet has no relative URL
    return nil;
}

- (NSDictionary *)headers {
    NSString *device;
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        device=@"iPhone";
    else
        device=@"iPad";
#ifdef TEST
    NSString *userAgent=[NSString stringWithFormat:@"DeviceType=%@;AppVersion=240.5", device];
#else
    NSString *userAgent=[NSString stringWithFormat:@"DeviceType=%@;AppVersion=%@", device, [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
#endif

    return @{@"User-Agent":userAgent, @"Content-Type": @"application/json"}; // no headers by default
}

- (NSDictionary *)params {
    return @{}; // no API method's input parameters by default
}

- (void (^)(id<AFMultipartFormData> formData))bodyConstructionBlock {
    return nil;
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST; // for our server default HTTP method is POST
}

- (GDXRESTPacketOptions *)options {
    GDXRESTPacketOptions *options = [GDXRESTPacketOptions new];
    options.cacheAllowed = NO; // forbid cache
    options.silent = NO; // silent requests, see 'GDXRESTPacketOptions' explanation below
    options.repeatOnSuccess = NO; // should be auto-repeated on success
    options.repeatOnFailure = NO; // should be auto-repeated on failure
    options.timeout = 30; // request timeout
    
    return options;
}

- (GDXRESTOperationType)requestType {
    return ((self.type == GDXRESTPacketTypePOST || self.type == GDXRESTPacketTypePUT)
            ? GDXRESTOperationTypeJSON // JSON for POST
            : GDXRESTOperationTypeHTTP); // HTTP for GET
}

- (GDXRESTOperationType)responseType {
    return GDXRESTOperationTypeJSON;
}

@end
