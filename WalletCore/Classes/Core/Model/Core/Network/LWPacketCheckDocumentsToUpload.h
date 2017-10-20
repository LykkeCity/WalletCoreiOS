//
//  LWPacketCheckDocumentsToUpload.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 12.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"
#import "LWDocumentsStatus.h"


@interface LWPacketCheckDocumentsToUpload : LWAuthorizePacket {
    
}
// out
@property (readonly, nonatomic) LWDocumentsStatus *documentsStatus;

@end
