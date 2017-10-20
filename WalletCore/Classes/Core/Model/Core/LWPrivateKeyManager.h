//
//  LWPrivateKeyManager.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 20/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//


//words for c1@c1.com: size odor choose rare sweet recipe render hour forget used resource ill
//words for c2@c2.com: market sister page gorilla unusual arctic lava off fresh number report pull

#import <Foundation/Foundation.h>
@import UIKit;
@class BTCKey;
typedef enum {BACKUP_MODE_PRIVATE_KEY, BACKUP_MODE_COLD_STORAGE} BACKUP_MODE;



@interface LWPrivateKeyManager : NSObject


@property (strong, readonly) BTCKey *privateKeyLykke;
@property (strong, readonly) NSString *encryptedKeyLykke;
@property (strong, readonly) NSString *publicKeyLykke;
@property (strong, readonly) NSString *wifPrivateKeyLykke;

@property (strong, nonatomic) void(^backgroudFetchCompletionHandler)(UIBackgroundFetchResult result);//(void (^)(UIBackgroundFetchResult))completionHandler;


+ (instancetype)shared;

-(BOOL) isDevServer;

//-(void) generatePrivateKey;
-(void) decryptLykkePrivateKeyAndSave:(NSString *) encodedPrivateKey;

-(NSString *) decryptPrivateKey:(NSString *)encryptedPrivateKeyData withPassword:(NSString *) password;

-(NSString *) encryptKey:(NSString *) privateKey password:(NSString *) password;

-(NSString *) encryptExternalWalletKey:(NSString *) wif;
-(NSString *) decryptExternalWalletKey:(NSString *) encryptedKey;

-(NSString *) encryptEthereumPrivateKey:(NSData *) ethKeyData;
-(NSString *) decryptEthereumPrivateKey:(NSString *) encodedEthKey;


+(NSString *) addressFromPrivateKeyWIF:(NSString *) wif;

+(NSString *) encodedPrivateKeyWif:(NSString *) key withPassPhrase:(NSString *) passPhrase;
+(NSString *) decodedPrivateKeyWif:(NSString *) encodedKey withPassPhrase:(NSString *) passPhrase;


-(NSString *) availableSecondaryPrivateKey;
-(NSString *) secondaryPrivateKeyFromPrivateWalletAddress:(NSString *) addressOfPrivateWallet;

-(NSString *) signatureForMessageWithLykkeKey:(NSString *) message;
-(NSString *) coloredAddressFromBitcoinAddress:(NSString *) address;

+(NSString *) hashForString:(NSString *) string;


+(NSArray *) generateSeedWords12;
+(NSArray *) generateSeedWords24;
-(NSArray *) privateKeyWords;
-(BOOL) savePrivateKeyLykkeFromSeedWords:(NSArray *) words;
+(NSData *) keyDataFromSeedWords:(NSArray *) words;

+(NSString *) wifKeyFromData:(NSData *) data;

+(BOOL) isAddressColored:(NSString *) address;

//-(void) signEthereumTransactions:(NSArray *) arr;

-(void) signatureSent;

//-(void) createETHAddressAndPubKeyWithCompletion:(void(^)(NSDictionary *)) completion;

-(void) logoutUser;

-(BOOL) isPrivateKeyLykkeEmpty;

-(BTCKey *) generateKey;
-(NSData *) generateRandomKeyData32;
-(NSData *) generateRandomKeyData16;

@end
