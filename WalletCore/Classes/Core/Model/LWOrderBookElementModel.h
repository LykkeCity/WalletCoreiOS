//
//  LWOrderBookElementModel.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 09/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWOrderBookElementModel : NSObject

@property BOOL isVolumeCumulative;

-(id) initWithArray:(NSArray *) array;
-(double) priceForVolume:(double) volume;
-(double) priceForResult:(double)volumeOrig;

-(BOOL) isVolumeOK:(double) volume;
-(BOOL) isResultOK:(double) result;

-(void) invert;

-(NSArray *) array;



@end
