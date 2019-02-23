//
//  LWPacketBankCards.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 31.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@class LWBankCardsAdd;


@interface LWPacketBankCards : LWAuthorizePacket {
    
}
// in
@property (strong, nonatomic) LWBankCardsAdd *addCardData;

@end
