//
//  LWPacketKYCSendDocument.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 12.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPersonalDataPacket.h"
#import "LWDocumentsStatus.h"


@interface LWPacketKYCSendDocument : LWPersonalDataPacket {
    
}
// in
@property (copy, nonatomic)   NSData           *imageJPEGRepresentation;
@property (assign, nonatomic) KYCDocumentType  docType;

@end
