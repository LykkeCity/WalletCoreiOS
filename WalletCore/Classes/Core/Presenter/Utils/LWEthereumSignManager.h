//
//  LWEthereumSignManager.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 03/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWEthereumSignManager : NSObject

-(id) initWithEthPrivateKey:(NSString *) key withCompletion:(void(^)(void)) completion;

-(NSString *) signHash:(NSString *) hash;
-(NSDictionary *) createAddressAndPubKey;

@end
