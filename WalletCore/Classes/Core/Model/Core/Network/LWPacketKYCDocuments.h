//
//  LWPacketKYCDocuments.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 12/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"
#import "LWKYCDocumentsModel.h"


@interface LWPacketKYCDocuments : LWAuthorizePacket

@property (strong, nonatomic) LWKYCDocumentsModel *documentsStatuses;

@end
