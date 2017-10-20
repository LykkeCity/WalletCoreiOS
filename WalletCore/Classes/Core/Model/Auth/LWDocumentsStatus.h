//
//  LWDocumentsStatus.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 13.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KYCDocumentType) {
    KYCDocumentTypeSelfie,
    KYCDocumentTypeIdCard,
    KYCDocumentTypeProofOfAddress
};


@interface LWDocumentsStatus : LWJSONObject {
    
}

@property (readonly, nonatomic) BOOL selfie;
@property (readonly, nonatomic) BOOL idCard;
@property (readonly, nonatomic) BOOL proofOfAddress;
// utils
@property (readonly, nonatomic) BOOL isSelfieUploaded;
@property (readonly, nonatomic) BOOL isIdCardUploaded;
@property (readonly, nonatomic) BOOL isPOAUploaded;

@property (readonly, nonatomic) BOOL isSelfieCropped;
@property (readonly, nonatomic) BOOL isIdCardCropped;
@property (readonly, nonatomic) BOOL isPOACropped;

@property (readonly, nonatomic) double selfieCompression;
@property (readonly, nonatomic) double idCardCompression;
@property (readonly, nonatomic) double poaCompression;

@property (readonly, nonatomic) NSNumber *documentTypeRequired;

// image copy for already upload validation
@property (copy, nonatomic) UIImage *selfieLastImage;
@property (copy, nonatomic) UIImage *idCardLastImage;
@property (copy, nonatomic) UIImage *poaLastImage;

#pragma mark - Utils

- (void)setTypeUploaded:(KYCDocumentType)type withImage:(UIImage *)image;
- (UIImage *)lastUploadedImageForType:(KYCDocumentType)type;

- (void)setCroppedStatus:(KYCDocumentType)type withCropped:(BOOL)isCropped;
- (BOOL)croppedStatus:(KYCDocumentType)type;

- (void)resetTypeUploaded:(KYCDocumentType)type;

- (void)setDocumentType:(KYCDocumentType)type compression:(double)compression;
- (double)compression:(KYCDocumentType)type;

@end
