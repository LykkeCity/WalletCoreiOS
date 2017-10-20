//
//  LWEthereumSignManager.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 03/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWEthereumSignManager.h"

@import UIKit;

@interface LWEthereumSignManager() <UIWebViewDelegate>
{
    NSString *key;
    UIWebView *webView;
    
    
    void(^completionOfInit)(void);
//    void(^completionHashes)(NSArray *);
//    void(^completionAddress)(NSString *address, NSString *publicKey);

}

@end

@implementation LWEthereumSignManager

-(id) initWithEthPrivateKey:(NSString *) _key withCompletion:(void(^)(void)) completion
{
    self=[super init];
    completionOfInit=completion;
    
    key=_key;

    webView=[[UIWebView alloc] init];
    webView.delegate=self;
    
    NSString *path;
    NSBundle *thisBundle = [NSBundle mainBundle];
    path = [thisBundle pathForResource:@"lykke-ethereum" ofType:@"html"];
    NSURL *instructionsURL = [NSURL fileURLWithPath:path];
    [webView loadRequest:[NSURLRequest requestWithURL:instructionsURL]];


    
    return self;
}

-(NSString *) signHash:(NSString *) hash
{

    NSString *request=[NSString stringWithFormat:@"window.ethereumjs.signHash(\'%@\', \'%@\')", hash, key];
    return [webView stringByEvaluatingJavaScriptFromString:request];
    
}


-(NSDictionary *) createAddressAndPubKey
{
    NSString *sss=[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.ethereumjs.createAddress(\'0x%@\')", key]];
    NSArray *arr=[sss componentsSeparatedByString:@"-"];

    if(arr.count==2)
        return @{@"Address":arr[0], @"PubKey":arr[1]};
    return nil;
}

    
-(void) webViewDidFinishLoad:(UIWebView *)we
{
    completionOfInit();
    
}


@end
