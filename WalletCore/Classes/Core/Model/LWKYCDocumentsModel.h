//
//  LWKYCDocumentsModel.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 12/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWDocumentsStatus.h"
@class LWSendImageManager;

//typedef enum {KYCDocumentTypeSelfie, KYCDocumentTypePassport, KYCDocumentTypeAddress} KYCDocumentType;
typedef NS_ENUM(NSInteger, KYCDocumentStatus) {
    KYCDocumentStatusEmpty,
    KYCDocumentStatusUploaded,
    KYCDocumentStatusApproved,
    KYCDocumentStatusRejected
};


@interface LWKYCDocumentsModel : NSObject

-(void) setArrayOfDocuments:(NSArray *) array;

-(KYCDocumentStatus) statusForDocument:(KYCDocumentType) type;
-(void) setDocumentStatus:(KYCDocumentStatus) status forDocument:(KYCDocumentType) type;

-(void) saveImage:(UIImage *)image forType:(KYCDocumentType) type;

-(UIImage *) imageForType:(KYCDocumentType) type;
-(NSString *) imageUrlForType:(KYCDocumentType) type;

-(NSString *) commentForType:(KYCDocumentType) type;

-(void) sendImageManagerSentImage:(LWSendImageManager *)manager;
-(void) sendImageManager:(LWSendImageManager *) manager didSucceedWithData:(NSDictionary *) data;
-(void) sendImageManager:(LWSendImageManager *)manager didFailWithErrorMessage:(NSString *)message;

-(BOOL) isUploadingImage;

-(void) logout;

+(LWKYCDocumentsModel *) shared;

@end
