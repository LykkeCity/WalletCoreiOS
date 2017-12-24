//
//  LWPacketAuthentication.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 13.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacket.h"
#import "LWAuthenticationData.h"

@class LWPersonalDataModel;


@interface LWPacketAuthentication : LWPacket {
    
}
// in
@property (strong, nonatomic) LWAuthenticationData *authenticationData;
// out
@property (readonly, nonatomic) NSString       *token;
@property (readonly, nonatomic) NSString       *status;
@property (readonly, nonatomic) LWPersonalDataModel *personalData;
@property (readonly, nonatomic) BOOL            isPinEntered;

- (void)parseResponse:(id)response error:(NSError *)error;

@end
