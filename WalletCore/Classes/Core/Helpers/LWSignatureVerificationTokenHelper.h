//
//  LWSignatureVerificationTokenHelper.h
//  LykkeWallet
//
//  Created by vsilux on 20/11/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LWNetworkClient <NSObject>

- (id)sendRequest:(NSURLRequest *)request;
- (NSMutableURLRequest *)createRequestWithAPI:(NSString *)apiMethod
                                   httpMethod:(NSString *)httpMethod
                                getParameters:(NSDictionary *)getParams
                               postParameters:(NSDictionary *)postParams;

@end

@interface LWSignatureVerificationTokenHelper : NSObject

+ (void)networkClient:(id<LWNetworkClient>)client requestVerificationTokenFor:(NSString *)email
              success:(void (^)(NSString *signatureVerificationToken))success
               failur:(void (^)(NSError *error))failur;

@end
