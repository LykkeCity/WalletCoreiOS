//
//  LWSendImageManager.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWDocumentsStatus.h"



@interface LWSendImageManager : NSObject

@property id delegate;

@property KYCDocumentType type;

-(void) sendImageWithData:(NSData *) data type:(KYCDocumentType) type;
-(void) stopUploading;



@end


@protocol LWSendImageManagerDelegate


-(void) sendImageManager:(LWSendImageManager *) manager didFailWithErrorMessage:(NSString *) message;
-(void) sendImageManager:(LWSendImageManager *) manager didSucceedWithData:(NSDictionary *) data;
-(void) sendImageManagerSentImage:(LWSendImageManager *)manager;
-(void) sendImageManager:(LWSendImageManager *)manager changedProgress:(float) progress;

@end
