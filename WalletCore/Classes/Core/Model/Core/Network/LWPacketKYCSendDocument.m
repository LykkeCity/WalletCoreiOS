//
//  LWPacketKYCSendDocument.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 12.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacketKYCSendDocument.h"


@implementation LWPacketKYCSendDocument


#pragma mark - LWPacket

- (NSString *)urlRelative {
    return @"KycDocuments";
}

- (NSDictionary *)params {
    NSString *docTypeString = nil;
    
    switch (self.docType) {
        case KYCDocumentTypeIdCard: {
            docTypeString = @"IdCard";
            break;
        }
        case KYCDocumentTypeProofOfAddress: {
            docTypeString = @"ProofOfAddress";
            break;
        }
        case KYCDocumentTypeSelfie: {
            docTypeString = @"Selfie";
            break;
        }
    }
    return @{@"Type" : docTypeString,
             @"Ext" : @"jpeg",
             @"Data" : [self.imageJPEGRepresentation base64EncodedStringWithOptions:0]};
}

@end
