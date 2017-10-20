//
//  LWKYCDocumentsModel.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 12/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWKYCDocumentsModel.h"
#import "LWSendImageManager.h"
#import "LWKeychainManager.h"

@interface LWKYCDocumentsModel() <LWSendImageManagerDelegate>
{
    NSMutableDictionary *docs;
}

@end

@implementation LWKYCDocumentsModel

+ (instancetype)shared
{
    static LWKYCDocumentsModel *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[LWKYCDocumentsModel alloc] init];
    });
    return shared;
}


-(void) setArrayOfDocuments:(NSArray *)array
{
    if(!docs)
        docs=[[NSMutableDictionary alloc] init];
    for(NSDictionary *d in array)
    {
        KYCDocumentType type;
        if([d[@"Type"] isEqualToString:@"IdCard"])
            type=KYCDocumentTypeIdCard;
        else if([d[@"Type"] isEqualToString:@"ProofOfAddress"])
            type=KYCDocumentTypeProofOfAddress;
        else if([d[@"Type"] isEqualToString:@"Selfie"])
            type=KYCDocumentTypeSelfie;
        
        NSMutableDictionary *dict=[docs[@(type)] mutableCopy];
        if(!dict)
            dict=[[NSMutableDictionary alloc] init];
        dict[@"ID"]=d[@"DocumentId"];
        if([d[@"DocumentState"] isEqualToString:@"Uploaded"])
            dict[@"Status"]=@(KYCDocumentStatusUploaded);
        else if([d[@"DocumentState"] isEqualToString:@"Approved"])
            dict[@"Status"]=@(KYCDocumentStatusApproved);
        else if([d[@"DocumentState"] isEqualToString:@"Declined"])
            dict[@"Status"]=@(KYCDocumentStatusRejected);
        if(d[@"KycComment"])
            dict[@"Comment"]=d[@"KycComment"];
        
        docs[@(type)]=dict;
    }
    
}

-(KYCDocumentStatus) statusForDocument:(KYCDocumentType)type
{
    if(docs[@(type)])
        return [docs[@(type)][@"Status"] intValue];
    
    return KYCDocumentStatusEmpty;
}

-(void) setDocumentStatus:(KYCDocumentStatus)status forDocument:(KYCDocumentType)type
{
    if(docs[@(type)])
        docs[@(type)][@"Status"]=@(status);
    else
    {
        NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
        dict[@"Status"]=@(status);
        docs[@(type)]=dict;
    }
}

-(UIImage *) imageForType:(KYCDocumentType)type
{
    if(docs[@(type)][@"Image"] != nil)
        return docs[@(type)][@"Image"];
    
    return nil;
}

-(NSString *) imageUrlForType:(KYCDocumentType)type
{
    if(docs[@(type)][@"ID"])
    {
        return [NSString stringWithFormat:@"https://%@/api/KycDocumentsBin/%@?width=320", [LWKeychainManager instance].address, docs[@(type)][@"ID"]];
    }
    
    return nil;
}

-(void) saveImage:(UIImage *)image forType:(KYCDocumentType)type
{
    if(docs[@(type)])
        docs[@(type)][@"Image"]=image;
    else
    {
        NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
        dict[@"Image"]=image;
        docs[@(type)]=dict;
    }
    if(docs[@(type)][@"Uploader"])
    {
        LWSendImageManager *manager=docs[@(type)][@"Uploader"];
        [manager stopUploading];
    }
    LWSendImageManager *manager=[[LWSendImageManager alloc] init];
    manager.delegate=self;
    docs[@(type)][@"Uploader"]=manager;
    [manager sendImageWithData:UIImageJPEGRepresentation(image, 0.8) type:type];
    
}

-(NSString *) commentForType:(KYCDocumentType)type
{
    return docs[@(type)][@"Comment"];
}

-(BOOL) isUploadingImage
{
    for(NSMutableDictionary *d in docs.allValues)
        if(d[@"Uploader"])
        {
            return YES;
        }
    return NO;
}

-(void) sendImageManagerSentImage:(LWSendImageManager *)manager
{
    for(NSMutableDictionary *d in docs.allValues)
        if(d[@"Uploader"]==manager)
        {
            [d removeObjectForKey:@"Uploader"];
            break;
        }
}

-(void) logout
{
    
    docs=nil;
}

-(void) sendImageManager:(LWSendImageManager *)manager didFailWithErrorMessage:(NSString *)message
{
    for(NSMutableDictionary *d in docs.allValues)
        if(d[@"Uploader"]==manager)
        {
            [d removeObjectForKey:@"Uploader"];
            break;
        }

}

-(void) sendImageManager:(LWSendImageManager *) manager didSucceedWithData:(NSDictionary *) data {
    for(NSMutableDictionary *d in docs.allValues)
        if(d[@"Uploader"]==manager)
        {
            [d removeObjectForKey:@"Uploader"];
            break;
        }
}

-(void) sendImageManager:(LWSendImageManager *)manager changedProgress:(float)progress
{
    
}

@end
