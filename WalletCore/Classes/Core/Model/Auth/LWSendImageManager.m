//
//  LWSendImageManager.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWSendImageManager.h"
#import "LWKeychainManager.h"
#import "LWPersonalDataModel.h"

@interface LWSendImageManager() <NSURLConnectionDelegate>
{
    NSURLConnection *connection;
}

@end

@implementation LWSendImageManager



-(void) sendImageWithData:(NSData *) data type:(KYCDocumentType) typeOfPost
{
    self.type=typeOfPost;
    NSString *docTypeString = nil;
    
    switch (typeOfPost) {
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

    NSString *baseurl = [NSString stringWithFormat:@"https://%@/api/KycDocumentUpload?Type=%@", [LWKeychainManager instance].address, docTypeString];
    
    NSURL *url = [NSURL URLWithString:baseurl];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod: @"POST"];
    [urlRequest setValue:[NSString stringWithFormat:@"Bearer %@", [LWKeychainManager instance].token] forHTTPHeaderField:@"Authorization"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [urlRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@.jpg\"\r\n", @"photo"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPBody:postbody];

    
    
    
    connection=[NSURLConnection connectionWithRequest:urlRequest delegate:self];
    [connection start];
    
    
    

}

-(void) stopUploading
{
    [connection cancel];
}


- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Did Receive Response %@", response);
    if([(NSHTTPURLResponse *)response statusCode]!=200)
    {
//        if([self.delegate respondsToSelector:@selector(didFailWithErrorMessage:)])
            [self.delegate sendImageManager:self didFailWithErrorMessage:@"Upload failed!"];
    }
    
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if([self.delegate respondsToSelector:@selector(sendImageManager:changedProgress:)])
        [self.delegate sendImageManager:self changedProgress:(float)totalBytesWritten/totalBytesExpectedToWrite];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    if(data)
    {
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if(dict && dict[@"Result"] && [dict[@"Result"] isKindOfClass:[NSDictionary class]])
        {
            LWPersonalDataModel *personalData = [[LWPersonalDataModel alloc]
                                            initWithJSON:[dict[@"Result"] objectForKey:@"PersonalData"]];
            [[LWKeychainManager instance] savePersonalData:personalData];
    
            [self.delegate sendImageManager:self didSucceedWithData: dict];
        } else if (dict && dict[@"Error"] && [dict[@"Error"] isKindOfClass:[NSDictionary class]]) {
            
            NSString* message = dict[@"Error"][@"Message"];
            
//            if([self.delegate respondsToSelector:@selector(didFailWithErrorMessage:)])
                [self.delegate sendImageManager:self didFailWithErrorMessage: message];
        }
    }
    
    
    NSString *str=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Data recieved from server while uploading image: %@", str);
}
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    if([self.delegate respondsToSelector:@selector(sendImageManager:didFailWithErrorMessage:)])
        [self.delegate sendImageManager:self didFailWithErrorMessage:@"Upload failed!"];
    
    NSLog(@"Did Fail");
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if([self.delegate respondsToSelector:@selector(sendImageManagerSentImage:)])
        [self.delegate sendImageManagerSentImage:self];

    NSLog(@"Did Finish");
}


@end
