//
//  LWPacketAccountExist.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 10.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacket.h"


@interface LWPacketAccountExist : LWPacket {
    
}
// in
@property (copy, nonatomic) NSString *email;
// out
@property (readonly, nonatomic) BOOL isRegistered;
@property (readonly, nonatomic) BOOL hasHint;

-(void) saveValues;

@end
