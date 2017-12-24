//
//  LWNetworkTemplate.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 07/04/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWNetworkTemplate : NSObject


-(id) sendRequest:(NSURLRequest *) request;
-(NSMutableURLRequest *) createRequestWithAPI:(NSString *) apiMethod httpMethod:(NSString *) httpMethod getParameters:(NSDictionary *) getParams postParameters:(NSDictionary *) postParams;



@end
