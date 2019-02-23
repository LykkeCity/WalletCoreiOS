//
//  LWJSONObject.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 27.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"


@implementation LWJSONObject {
    
}


#pragma mark - Root

- (instancetype)initWithJSON:(id)json {
    self = [super init];
    return self;
}

+ (EKObjectMapping *)objectMapping {
	return [EKObjectMapping mappingForClass:self withBlock:^(EKObjectMapping *mapping) {
		
	}];
}

@end
