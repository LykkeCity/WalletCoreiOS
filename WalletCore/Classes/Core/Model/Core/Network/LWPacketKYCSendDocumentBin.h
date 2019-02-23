//
//  LWPacketKYCSendDocumentBin.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 30.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPersonalDataPacket.h"
#import "LWDocumentsStatus.h"


@interface LWPacketKYCSendDocumentBin : LWPersonalDataPacket {
    
}
// in
@property (copy, nonatomic)   NSData           *imageJPEGRepresentation;
@property (assign, nonatomic) KYCDocumentType  docType;

@end
