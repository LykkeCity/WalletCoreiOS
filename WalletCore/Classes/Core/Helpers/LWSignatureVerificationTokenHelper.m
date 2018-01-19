//
//  LWSignatureVerificationTokenHelper.m
//  LykkeWallet
//
//  Created by vsilux on 20/11/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWSignatureVerificationTokenHelper.h"
#import "LWNetworkTemplate.h"
#import "LWPrivateKeyManager.h"
#import "WalletCoreConfig.h"

@implementation LWSignatureVerificationTokenHelper

+ (void)networkClient:(id<LWNetworkClient>)client requestVerificationTokenFor:(NSString *)email
              success:(void (^)(NSString *signatureVerificationToken))success
               failur:(void (^)(NSError *error))failur {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSURLRequest *requestSignature = [client createRequestWithAPI:@"signatureVerificationToken/KeyConfirmation" httpMethod:kMethodGET getParameters:@{@"email": email, @"partnerId": WalletCoreConfig.partnerId} postParameters:nil];
    id response = [client sendRequest:requestSignature];
    if (response == nil || ![response isKindOfClass:[NSDictionary class]]) {
        if ([response isKindOfClass:[NSError class]]) {
            failur(response);
        } else {
            failur(nil);
        }
        return;
    }
    NSString *message = response[@"Message"];
    if (message == nil) {
      NSError *error = [NSError errorWithDomain:@"com.lykke.wallet.LWSignatureVerificationTokenHelper" code:-1126 userInfo:nil];
      failur(error);
    }
    NSString *signedMessage = [[LWPrivateKeyManager shared] signatureForMessageWithLykkeKey:message];
    if (signedMessage == nil) {
      NSError *error = [NSError errorWithDomain:@"com.lykke.wallet.LWSignatureVerificationTokenHelper" code:-1127 userInfo:nil];
      failur(error);
    }
    NSURLRequest *requestVerificationToken = [client createRequestWithAPI:@"signatureVerificationToken/KeyConfirmation" httpMethod:kMethodPOST getParameters:nil postParameters:@{@"Email": email, @"SignedMessage": signedMessage, @"PartnerId": WalletCoreConfig.partnerId}];
    response = [client sendRequest:requestVerificationToken];
    if ([response isKindOfClass:[NSDictionary class]] && response[@"AccessToken"] != nil) {
      success(response[@"AccessToken"]);
    } else {
      failur(response);
    }
  });
}

@end
