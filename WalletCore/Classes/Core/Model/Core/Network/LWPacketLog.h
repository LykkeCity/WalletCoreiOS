//
//  LWPacketLog.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 28.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@interface LWPacketLog : LWAuthorizePacket {
    
}
// in
@property (copy, nonatomic) NSString *log;

@end
