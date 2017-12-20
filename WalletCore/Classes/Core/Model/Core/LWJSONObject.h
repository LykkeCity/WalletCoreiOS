//
//  LWJSONObject.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 27.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EasyMapping/EasyMapping.h>

@interface LWJSONObject : NSObject <EKMappingProtocol> {
    
}


#pragma mark - Root

- (instancetype)initWithJSON:(id)json;

@end
