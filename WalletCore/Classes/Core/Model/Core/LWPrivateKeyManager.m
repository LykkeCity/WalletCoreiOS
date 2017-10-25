//
//  LWPrivateKeyManager.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 20/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateKeyManager.h"
#import "LWKeychainManager.h"
#import "NewDecodeBase64.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <CoreBitcoin/BTCKey.h>
#import <CoreBitcoin/BTCAddress.h>
#import <CoreBitcoin/BTCBase58.h>
#import "LWEthereumSignManager.h"
#import "LWSignRequestModel.h"
#import "LWAuthManager.h"
#import "LWUtils.h"
#import "LWPrivateWalletsManager.h"
#import "LWPrivateWalletModel.h"

//#import "ecdsa.h"
//#import "secp256k1.h"
//#import "curves.h"
#import "LWConstantsLykke.h"
//#import "sha2.h"
#import "LWUtils.h"


@import Security;

@interface LWPrivateKeyManager()
{
//    LWEthereumSignManager *ethManager;
    int numberOfSignedTransactionsSent;
}

@end

@implementation NSData (NYMnemonic)
- (NSString *)ny_hexString {
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    
    if (!dataBuffer) {
        return [NSString string];
    }
    
    NSUInteger dataLength = [self length];
    NSMutableString *hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for (int i = 0; i < dataLength; ++i) {
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    
    return [NSString stringWithString:hexString];
}

- (NSArray *)ny_hexToBitArray {
    NSMutableArray *bitArray = [NSMutableArray arrayWithCapacity:(int)self.length * 8];
    NSString *hexStr = [self ny_hexString];
    // Loop over the string and convert each char
    for (NSUInteger i = 0; i < [hexStr length]; i++) {
        NSString *bin = [self _hexToBinary:[hexStr characterAtIndex:i]];
        // Each character will return a string representation of the binary
        // Create NSNumbers from each and append to the array.
        for (NSInteger j = 0; j < bin.length; j++) {
            [bitArray addObject:
             @([[NSString stringWithFormat: @"%C", [bin characterAtIndex: j]] intValue])];
        }
    }
    return [NSArray arrayWithArray:bitArray];
}

- (NSString *)_hexToBinary:(unichar)value {
    switch (value) {
        case '0': return @"0000";
        case '1': return @"0001";
        case '2': return @"0010";
        case '3': return @"0011";
        case '4': return @"0100";
        case '5': return @"0101";
        case '6': return @"0110";
        case '7': return @"0111";
        case '8': return @"1000";
        case '9': return @"1001";
            
        case 'a':
        case 'A': return @"1010";
            
        case 'b':
        case 'B': return @"1011";
            
        case 'c':
        case 'C': return @"1100";
            
        case 'd':
        case 'D': return @"1101";
            
        case 'e':
        case 'E': return @"1110";
            
        case 'f':
        case 'F': return @"1111";
    }
    return @"-1";
}

@end

@implementation NSString (NYMnemonic)
- (NSData *)ny_dataFromHexString {
    const char *chars = [self UTF8String];
    int i = 0, len = (int)self.length;
    
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = { '\0', '\0', '\0' };
    unsigned long wholeByte;
    
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    
    return data;
}

@end




@interface LWPrivateKeyManager()
{
    BTCKey *privateKeyForLykke;
}

@end

@implementation LWPrivateKeyManager

-(id) init
{
    self=[super init];
    
    
//    [LWPrivateKeyManager wordsFromKeyData:[LWUtils dataFromHexString:@"a8c974409dcf63f2644c9709fe09ccdc"]];
    
    
//    NSString *sss=[LWPrivateKeyManager addressFromPrivateKeyWIF:@"00000000 00000000 00000000 00000000 2ec32aee f6c434c6 ef0c6c83 e550d53d"];
    
    //cU7QSmzTpqtmi5pA4A2MFxxa5nTryCbffhmwXyYzEpwNkQgH8JXE
    
//    NSString *rrrr=[self encryptExternalWalletKey:@"cU7QSmzTpqtmi5pA4A2MFxxa5nTryCbffhmwXyYzEpwNkQgH8JXE"];
//    NSString *yyyy=[self decryptExternalWalletKey:rrrr];
//    
//    
//    BTCKey *kkk=[[BTCKey alloc] initWithWIF:@"cU7QSmzTpqtmi5pA4A2MFxxa5nTryCbffhmwXyYzEpwNkQgH8JXE"];
//    NSLog(@"%@", kkk.privateKey);
//    
//    BTCKey *eee=[[BTCKey alloc] initWithWIF:@"cU7QSmzTpqtmi5pA4A2MFxxbrPgjmGzChGVLKh98uPTho1rPzbAb"];
//    
//    NSLog(@"%@", eee.privateKey);
    
    
//    BTCKey *kkk=[[BTCKey alloc] initWithWIF:@"cMahea7zqjxrtgAbB7LSGbcR54eisG66j9t5pyQpCggJ3GQvkjPR"];
//    NSLog(@"%@", kkk.privateKey);
    
//    ethManager=[[LWEthereumSignManager alloc] initWithEthPrivateKey:@"0x4085dde01ea641a0f4fd6586ca11fc1f5df38e1bdcbef501da970cad9335b389"];
//    
//    [ethManager createAddress];
//    [ethManager signHash:@"0x67e547e0e11e33396f53ce559f089124cc12e54f936a166dd14798bf1677b5e8" withCompletion:^(NSString *hash){
//        NSLog(@"%@", hash);
//    
//    }];
    
//    NSArray *aaaa=[LWPrivateKeyManager generateSeedWords24];
//    NSData *data=[LWPrivateKeyManager keyDataFromSeedWords:aaaa];
//    NSArray *bbb=[LWPrivateKeyManager wordsFromKeyData:data];
    
    
    
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(testMethod:) name:@"ColdStorageBackupFinished" object:nil];
    
    
//    NSString *sss=[self encryptExternalWalletKey:nil];
//    NSString *eee=[self decryptExternalWalletKey:sss];
//    
//    NSLog(@"%@", eee);
//    [self generatePrivateKey];

    
    
//    BTCKey *kkk1=[[BTCKey alloc] initWithWIF:@"cMahea7zqjxrtgAbB7LSGbcQt7gX5j3yY5pDFz8sw4ayZFKmkLXe"];
//    NSData *data1=kkk1.privateKey;
//    NSLog(@"%@", [LWUtils hexStringFromData:data1]);
// 
//    BTCKey *kkk2=[[BTCKey alloc] initWithWIF:@"cMahea7zqjxrtgAbB7LSGbcS7FJp6rxmugMCRgCJ5t9gr2BLnZbW"];
//    NSData *data2=kkk2.privateKey;
//    NSLog(@"%@", [LWUtils hexStringFromData:data2]);

    
//    NSString *kkk=[self decryptPrivateKey:@"74F15EC5FDD88F6287E3CFC88A9B8EBAC0484D4FE6767DFB616CD38E80C8571208B7D39AE09AD061BB9D3BE7189255DB62D3D2D14B346E904BCF7247518C9144" withPassword:@"111111"];
//    NSLog(@"%@", kkk);
//
    
//    privateKeyForLykke=[[BTCKey alloc] initWithWIF:@"cU6bPP5KN9kvM7zek2bRURr9ABeF92kRFuqX7o8B2ojCMGyCxgsv"];
//    
//    NSString *pubkey=[self publicKeyLykke];
//    int iii=pubkey.length;
//    NSLog(@"%@", pubkey);
//
    
    
    
//    [self generatePrivateKey];
//    
//    NSLog(@"%@  %@", privateKeyForLykke.WIFTestnet, privateKeyForLykke.addressTestnet.string);
    // 30	ae	4e	d9	94	c7	d9	de	80	bf	c2	89	c4	4c	d0	02
    
//    BTCKey *key=[[BTCKey alloc] initWithPrivateKey:[LWUtils dataFromHexString:@"30ae4ed994c7d9de80bfc289c44cd0023c8f75b90e2ecbd686c8d41fd2e1d9a7"]];
//    key.publicKeyCompressed=YES;
//    NSLog(@"%@", key.WIFTestnet);
//    NSLog(@"%@", key.address.string);
    
    return self;
}

+ (instancetype)shared
{
    static LWPrivateKeyManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[LWPrivateKeyManager alloc] init];
    });
    return shared;
}

+(BOOL) isAddressColored:(NSString *) address
{
    NSData *hashWithVersionByte=[BTCDataFromBase58(address) subdataWithRange:NSMakeRange(0, 21)];
    
    char *pointer=(char *)hashWithVersionByte.bytes;
    
    if(*pointer == (char)0x13) {
        return true;
    }
    
    return false;
}


-(NSString *) coloredAddressFromBitcoinAddress:(NSString *) address
{
    
    if([LWPrivateKeyManager isAddressColored:address]) {
        return address;
    }
    
    
    NSData *hashWithVersionByte=[BTCDataFromBase58(address) subdataWithRange:NSMakeRange(0, 21)];
    
    
    char *pointer=(char *)hashWithVersionByte.bytes;
    if(*pointer == (char) 0x13) {
        return address;
    }
//    BTCAddress *kkk=[BTCAddress addressWithString:address];
    
    char prefix[1];
    
    prefix[0]=0x13;
//    if([self isDevServer])
//        prefix[1]=0x6f;
//    else
//        prefix[1]=0x0;
    
    //C4A21CEE3EDC58582382D59C722C9B54B6281DA95A
//    if([self isDevServer])
//        prefix[1]=0xc4;
//    else
//        prefix[1]=0x0;
    NSMutableData *data=[NSMutableData dataWithBytes:prefix length:1];
    [data appendData:hashWithVersionByte];
    
    NSMutableData *hash=[NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (int)data.length, hash.mutableBytes);
    
    NSMutableData *hash1=[NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(hash.bytes, (int)hash.length, hash1.mutableBytes);
    
    [data appendBytes:hash1.bytes length:4];
    
    NSString *str=BTCBase58StringWithData(data);
    
    return BTCBase58StringWithData(data);
}

-(BOOL) savePrivateKeyLykkeFromSeedWords:(NSArray *) words
{
    NSData *privateKeyData=[LWPrivateKeyManager keyDataFromSeedWords:words];
    if(!privateKeyData)
        return NO;
    
    privateKeyForLykke=[[BTCKey alloc] initWithPrivateKey:privateKeyData];
    privateKeyForLykke.publicKeyCompressed=YES;
    NSString *wif;
    if([self isDevServer])
        wif=privateKeyForLykke.WIFTestnet;
    else
        wif=privateKeyForLykke.WIF;
    
    if([LWKeychainManager instance].password) {
        [[LWKeychainManager instance] saveEncodedLykkePrivateKey:self.encryptedKeyLykke];
        [[LWKeychainManager instance] saveNotEncodedPrivateKey:wif];
    }

    return YES;
}

-(NSString *) signatureForMessageWithLykkeKey:(NSString *) message
{
//    NSString *signature=[LWUtils hexStringFromData:[self.privateKeyLykke signatureForMessage:message]];
//    
//    message=@"TestMessage";
    
//    BTCKey *key=[[BTCKey alloc] init];
//    NSString *address=key.address.string;
  
    NSString *address=self.privateKeyLykke.addressTestnet.string;
    NSData *sign=[self.privateKeyLykke signatureForMessage:message];
    
    NSString *str=[sign base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
//    NSString *signature=[LWUtils hexStringFromData:sign];

    NSLog(@"%@", str);
    NSLog(@"%@", self.privateKeyLykke.address.string);
    NSLog(@"%@", message);
    
//    BTCKey *ttt=[BTCKey verifySignature:[LWUtils dataFromHexString:signature] forMessage:message];
//    NSLog(@"%@", ttt.address.publicAddress.string);
    
    
//    NSString *signature=[LWUtils hexStringFromData:[self.privateKeyLykke signatureForBinaryMessage:[LWUtils dataFromHexString:message]]];

    return str;
}

+(NSArray *) wordsFromKeyData:(NSData *) keyData
{
    
    int numOfBytes=keyData.length;
    
    NSData *data=[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"english_words_list" ofType:@"txt"]];
    NSString *string=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *lines=[string componentsSeparatedByString:@"\n"];
    
    NSData *seedData=keyData;

    NSLog(@"%@", seedData);
    
    // Calculate the sha256 hash to use with a checksum
    NSMutableData *hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(seedData.bytes, (int)seedData.length, hash.mutableBytes);
    
    NSMutableArray *checksumBits = [NSMutableArray
                                    arrayWithArray:[[NSData dataWithData:hash] ny_hexToBitArray]];
    NSMutableArray *seedBits =
    [NSMutableArray arrayWithArray:[seedData ny_hexToBitArray]];
    
//    NSArray *hashDigits = [hash ny_hexToBitArray];
//    
//    NSString *str = @"";
//    for(NSNumber *n in hashDigits) {
//        str = [str stringByAppendingFormat:@"%d", n.intValue];
//    }
    
    // Append the appropriate checksum bits to the seed
    for (int i = 0; i < (int)seedBits.count / 32; i++) {
        [seedBits addObject: checksumBits[i]];
    }
    
    // Split into groups of 11, and change to numbers
    NSMutableArray *words = [NSMutableArray arrayWithCapacity:(int)seedBits.count / 11];
    for (int i = 0; i < (int)seedBits.count / 11; i++) {
        NSUInteger wordNumber =
        strtol(
               [[[seedBits subarrayWithRange: NSMakeRange(i * 11, 11)] componentsJoinedByString: @""] UTF8String],
               NULL,
               2);
        
        [words addObject: lines[wordNumber]];
    }

    
    NSLog(@"%@", words);

    
    return words;
}

+(NSArray *) generateSeedWords12
{
    while(1)
    {
        NSData *keyData=[[LWPrivateKeyManager shared] generateRandomKeyData16];

        NSLog(@"%@", keyData);
        
        NSArray *arr=[LWPrivateKeyManager wordsFromKeyData:keyData];
        if([LWPrivateKeyManager isWordListUnique:arr])
            return arr;
    }
}

+(NSArray *) generateSeedWords24
{
    while(1)
    {

        NSData *keyData=[[LWPrivateKeyManager shared] generateRandomKeyData32];
        
        NSLog(@"%@", keyData);
        
        NSArray *arr=[LWPrivateKeyManager wordsFromKeyData:keyData];
        if([LWPrivateKeyManager isWordListUnique:arr])
            return arr;
    }
}


+(BOOL) isWordListUnique:(NSArray *) words
{
    BOOL flag=YES;
    for(int i=0;i<words.count-1;i++)
    {
        NSString *word=words[i];
        if([[words subarrayWithRange:NSMakeRange(i+1, words.count-i-1)] containsObject:word])
        {
            flag=NO;
            break;
        }
        
    }
    
    return flag;

}

-(NSArray *) privateKeyWords
{
    if(!privateKeyForLykke)
        return nil;
    NSData *data=privateKeyForLykke.privateKey;
    char *bytes=(char *)data.bytes;
    
    for(int i=0;i<16;i++)
    {
        if(bytes[i]!=0x0)
        {
            return nil;
        }
    }
    
    return [LWPrivateKeyManager wordsFromKeyData:[data subdataWithRange:NSMakeRange(16, 16)]];
}

+(NSData *) keyDataFromSeedWords:(NSArray *) words
{
    if(words.count!=12 && words.count!=24)
        return nil;
    NSData *data=[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"english_words_list" ofType:@"txt"]];
    NSString *string=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *lines=[string componentsSeparatedByString:@"\n"];
    
    NSMutableArray *dataBits=[[NSMutableArray alloc] init];
    for(NSString *s in words)
    {
        if(s.length==0 || [lines indexOfObject:s]==NSNotFound)
        {
            return nil;
        }
        int index=(int)[lines indexOfObject:s];
        char *c=(char *)&index;
        c[2]=c[0];
        c[0]=c[1];
        c[1]=c[2];
        NSData *d=[NSData dataWithBytes:&index length:2];
        NSArray *bits=[d ny_hexToBitArray];
        [dataBits addObjectsFromArray:[bits subarrayWithRange:NSMakeRange(5, 11)]];
        NSLog(@"%@", [dataBits componentsJoinedByString:@""]);
    }
    
    int numOfBytes;
    if(words.count==12)
        numOfBytes=17;
    else
        numOfBytes=33;
    
    char *bytes=malloc(numOfBytes);
    for(int i=0;i<numOfBytes;i++)
        bytes[i]=0x0;
    
    for(int i=0;i<numOfBytes;i++)
    {
        for(int j=0;j<8;j++)
        {
            if(i==16 && j==4 && numOfBytes==17)
                break;
            char byte=bytes[i];
            byte=byte<<1;
            char mul=(char)[dataBits[i*8+j] intValue];
            byte=byte | mul;
            bytes[i]=byte;
        }
    }
    
    NSData *keyData=[NSData dataWithBytes:bytes length:numOfBytes-1];
    
    NSLog(@"%@", keyData);
    
    NSMutableData *hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(keyData.bytes, (int)keyData.length, hash.mutableBytes);
    
    char *checksum=(char *)hash.mutableBytes;
    if(numOfBytes==17)
    {
        *checksum=*checksum>>4;
        *checksum=*checksum&0x0f;
    }
    
    if(*checksum!=bytes[numOfBytes-1])
        return nil;

    free(bytes);

    NSMutableData *finalData=[[NSMutableData alloc] init];
    if(numOfBytes==17)
    {
        for(int i=0;i<16;i++)
        {
            char byte=0x0;
            [finalData appendBytes:&byte length:1];
        }
    }
    [finalData appendData:keyData];
    
    return finalData;
}

+(NSString *) wifKeyFromData:(NSData *)data
{
    BTCKey *key=[[BTCKey alloc] initWithPrivateKey:data];
    key.publicKeyCompressed=YES;
    return [[LWPrivateKeyManager shared] isDevServer]?key.WIFTestnet:key.WIF;
}

+(NSString *) hashForString:(NSString *) string
{
    NSData *data=[string dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSMutableData *hash=[NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (int)data.length, hash.mutableBytes);
    
    NSLog(@"%@", [LWUtils hexStringFromData:hash]);
    
    return [LWUtils hexStringFromData:hash];
}

-(NSString *) availableSecondaryPrivateKey
{
    NSArray *wallets=[LWPrivateWalletsManager shared].wallets;
    NSMutableData *data=[self.privateKeyLykke.privateKey mutableCopy];
    
    
    NSLog(@"%@", [LWUtils hexStringFromData:data]);
    char *pointer=data.mutableBytes;
    for(int i=0;i<255;i++)
    {
        *pointer=*pointer+1;
        BTCKey *key=[[BTCKey alloc] initWithPrivateKey:data];
        key.publicKeyCompressed=YES;
        NSString *address;
        if([self isDevServer])
            address=key.addressTestnet.string;
        else
            address=key.address.string;
        
        BOOL found=NO;
        for(LWPrivateWalletModel *w in wallets)
        {
            if([w.address isEqualToString:address])
            {
                found=YES;
                break;
            }
        }
        if(!found)
            return [self isDevServer]?key.WIFTestnet:key.WIF;
    }
    return nil;
}

-(NSString *) secondaryPrivateKeyFromPrivateWalletAddress:(NSString *) addressOfPrivateWallet
{
    if(!privateKeyForLykke)
        return nil;
    NSMutableData *data=[self.privateKeyLykke.privateKey mutableCopy];
    
    
    NSLog(@"%@", [LWUtils hexStringFromData:data]);
    char *pointer=data.mutableBytes;
    for(int i=0;i<255;i++)
    {
        *pointer=*pointer+1;
        BTCKey *key=[[BTCKey alloc] initWithPrivateKey:data];
        key.publicKeyCompressed=YES;
        NSString *address;
        if([self isDevServer])
            address=key.addressTestnet.string;
        else
            address=key.address.string;
        
        if([address isEqualToString:addressOfPrivateWallet])
            return [self isDevServer]?key.WIFTestnet:key.WIF;

    }
    return nil;

}

+(NSString *) addressFromPrivateKeyWIF:(NSString *)wif
{
    BTCKey *key=[[BTCKey alloc] initWithWIF:wif];
    if([[LWPrivateKeyManager shared] isDevServer])
        return key.addressTestnet.string;
    else
        return key.address.string;
}

-(NSString *) wifPrivateKeyLykke
{
    [self privateKeyLykke];
    
    if(!privateKeyForLykke)
        return nil;
    NSString *wif;
    if([self isDevServer])
        wif=privateKeyForLykke.WIFTestnet;
    else
        wif=privateKeyForLykke.WIF;
    return wif;
}

-(BOOL) isPrivateKeyLykkeEmpty
{
    return self.privateKeyLykke == nil;
}

-(BTCKey *) privateKeyLykke
{
    if(privateKeyForLykke)
        return privateKeyForLykke;
    if([LWKeychainManager instance].encodedPrivateKeyLykke)
    {
        NSString *decoded=[self decryptPrivateKey:[LWKeychainManager instance].encodedPrivateKeyLykke withPassword:[LWKeychainManager instance].password];
        privateKeyForLykke=[[BTCKey alloc] initWithWIF:decoded];
    }
    return privateKeyForLykke;
}

-(NSString *) publicKeyLykke
{
    if(!self.privateKeyLykke)
        return nil;
    NSData *publicKey=privateKeyForLykke.compressedPublicKey;
    return [LWUtils hexStringFromData:privateKeyForLykke.publicKey];
    
}

-(void) decryptLykkePrivateKeyAndSave:(NSString *)encodedPrivateKey
{
    NSString *privateKeyWif=[self decryptPrivateKey:encodedPrivateKey withPassword:[LWKeychainManager instance].password];
    
//    NSData *ddd = [LWPrivateKeyManager keyDataFromSeedWords:[@"potato entry awake describe wage weird muffin napkin antique utility industry reunion" componentsSeparatedByString:@" "]];
    
    if(privateKeyWif)
    {
        privateKeyForLykke=[[BTCKey alloc] initWithWIF:privateKeyWif];
        
        [[LWKeychainManager instance] saveEncodedLykkePrivateKey:encodedPrivateKey];
        [[LWKeychainManager instance] saveNotEncodedPrivateKey:privateKeyWif];

    }
    
    
}


-(BOOL) isDevServer
{
    if([[LWKeychainManager instance].address isEqualToString:kProductionServer] || [[LWKeychainManager instance].address isEqualToString:kStagingTestServer])
        return NO;
    return YES;
}

-(NSString *) encryptedKeyLykke
{
    if(!self.privateKeyLykke)
        return nil;
    NSString *wif;
    if([self isDevServer])
        wif=privateKeyForLykke.WIFTestnet;
    else
        wif=privateKeyForLykke.WIF;
    
    
    return [self encryptKey:wif password:[LWKeychainManager instance].password];
}

-(NSString *) encryptExternalWalletKey:(NSString *) wif
{
    
//    wif=@"cVCRhAsCKxM9q23mFxQiHbdzsuhTWcQjTmC1QrYyjGVRU5An7NnX";
    
    BTCKey *keyToEncrypt=[[BTCKey alloc] initWithWIF:wif];
    
    NSMutableData *keyData=[[self.privateKeyLykke.privateKey subdataWithRange:NSMakeRange(16, 16)] mutableCopy];
    NSLog(@"%@", keyToEncrypt.privateKey);
//    NSLog(@"%@", keyData);

    size_t bufferSize = 32 + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));

//    NSData *tmpKeyToEncrypt=[@"01234567890123456789012345678901" dataUsingEncoding:NSASCIIStringEncoding];
//    keyData=[@"9876543210987654" dataUsingEncoding:NSASCIIStringEncoding];
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyData.bytes,
                                          kCCBlockSizeAES128,
                                          0x0,
                                          keyToEncrypt.privateKey.bytes,
                                          32,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    
    NSData *data;
    if (cryptStatus == kCCSuccess) {
        data=[NSData dataWithBytes:buffer length:32];
        free(buffer);
        return [LWUtils hexStringFromData:data];
    }
    
 
    
    free(buffer);
    return nil;
    
    
}


-(NSString *) decryptExternalWalletKey:(NSString *) encryptedKey
{
    [self privateKeyLykke];
    
    if(!privateKeyForLykke)
        return nil;
    NSMutableData *encryptedKeyData=[[LWUtils dataFromHexString:encryptedKey] mutableCopy];
    
    char bbb=0x0;
    while(encryptedKeyData.length<48)
    {
        [encryptedKeyData appendBytes:&bbb length:1];
    }

    
    NSMutableData *keyData=[[self.privateKeyLykke.privateKey subdataWithRange:NSMakeRange(16, 16)] mutableCopy];
//    NSLog(@"%@", keyToEncrypt.privateKey);
//    NSLog(@"%@", keyData);
    
    size_t bufferSize = 48 + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyData.bytes,
                                          kCCBlockSizeAES128,
                                          0x0,
                                          encryptedKeyData.bytes,
                                          48,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    
    NSData *data;
    
    if (cryptStatus == kCCSuccess) {
        data=[NSData dataWithBytes:buffer length:32];
        BTCKey *key=[[BTCKey alloc] initWithPrivateKey:data];
        key.publicKeyCompressed=YES;
        free(buffer);
        return [self isDevServer]?key.WIFTestnet:key.WIF;

    }
    
    
    free(buffer);
    return nil;
    
    
}

-(NSString *) encryptEthereumPrivateKey:(NSData *) ethKeyData
{
    NSMutableData *keyData=[[self.privateKeyLykke.privateKey subdataWithRange:NSMakeRange(16, 16)] mutableCopy];
    
    
    size_t bufferSize = 32 + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyData.bytes,
                                          kCCBlockSizeAES128,
                                          0x0,
                                          ethKeyData.bytes,
                                          32,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    
    NSData *data;
    if (cryptStatus == kCCSuccess) {
        data=[NSData dataWithBytes:buffer length:32];
        free(buffer);
        return [LWUtils hexStringFromData:data];
    }
    
    free(buffer);
    return nil;
    
    
}


-(NSString *) decryptEthereumPrivateKey:(NSString *)encodedEthKey {
    if(!privateKeyForLykke)
        return nil;
    NSMutableData *encryptedKeyData=[[LWUtils dataFromHexString:encodedEthKey] mutableCopy];
    
    char bbb=0x0;
    while(encryptedKeyData.length<48)
    {
        [encryptedKeyData appendBytes:&bbb length:1];
    }
    
    
    NSMutableData *keyData=[[self.privateKeyLykke.privateKey subdataWithRange:NSMakeRange(16, 16)] mutableCopy];
    //    NSLog(@"%@", keyToEncrypt.privateKey);
    //    NSLog(@"%@", keyData);
    
    size_t bufferSize = 48 + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyData.bytes,
                                          kCCBlockSizeAES128,
                                          0x0,
                                          encryptedKeyData.bytes,
                                          48,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    
    NSData *data;
    
    if (cryptStatus == kCCSuccess) {
        data=[NSData dataWithBytes:buffer length:32];
        
        free(buffer);
        return [LWUtils hexStringFromData:data];
        
    }
    
    
    free(buffer);
    return nil;

}



-(NSString *) encryptKey:(NSString *) privateKey password:(NSString *) password
{
    NSString *string=privateKey;
    NSMutableData *ddd=[[string dataUsingEncoding:NSASCIIStringEncoding] mutableCopy];
    
    while ([ddd length]<64)
    {
        [ddd appendBytes:"" length:1];
    }
    
    NSString *key=password;
    if(key.length>16)
    {
        key=[key substringToIndex:16];
    }
    else if(key.length<16)
    {
        while(key.length<16)
            key=[key stringByAppendingString:@" "];
    }
    
    NSData *data=[self AES256Encrypt:ddd WithKey:key];
    
    
    return [LWUtils hexStringFromData:data];
    
}


+(NSString *) encodedPrivateKeyWif:(NSString *) key withPassPhrase:(NSString *) passPhrase
{
    NSData *dataIn = [passPhrase dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *macOut = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(dataIn.bytes, dataIn.length,  macOut.mutableBytes);
    
    NSMutableData *keyData=[NSMutableData dataWithData:[key dataUsingEncoding:NSASCIIStringEncoding]];
    char byte=0x0;
    while(keyData.length%32!=0)
        [keyData appendBytes:&byte length:1];
    
    NSData *encodedKey=[[LWPrivateKeyManager shared] AES256Encrypt:keyData withDataKey:macOut];
    
    NSString *ddd=[LWPrivateKeyManager decodedPrivateKeyWif:[LWUtils hexStringFromData:encodedKey] withPassPhrase:passPhrase];
    
    return [LWUtils hexStringFromData:encodedKey];
}

+(NSString *) decodedPrivateKeyWif:(NSString *) encodedKey withPassPhrase:(NSString *) passPhrase
{
    NSData *dataIn = [passPhrase dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *macOut = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(dataIn.bytes, dataIn.length,  macOut.mutableBytes);
    NSData *decodedKey=[[LWPrivateKeyManager shared] AES256Decrypt:[LWUtils dataFromHexString:encodedKey] withDataKey:macOut];
    
    NSString *str=[[NSString alloc] initWithBytes:decodedKey.bytes length:strlen(decodedKey.bytes) encoding:NSASCIIStringEncoding];
    
    
    return str;
}

- (NSData *)AES256Decrypt:(NSData *) data withDataKey:(NSData *)key {
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES, kCCOptionECBMode,
                                          key.bytes, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}



- (NSData *)AES256Encrypt:(NSData *) data withDataKey:(NSData *)key {
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES, kCCOptionECBMode,
                                          key.bytes, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}




- (NSData *)AES256Encrypt:(NSData *) data WithKey:(NSString *)key {
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES, kCCOptionECBMode,
                                          keyPtr, kCCKeySizeAES128,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

- (NSData*)AES256DecryptData:(NSData *) data WithKey:(NSString*)key {
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256 + 1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize           = dataLength + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    size_t numBytesDecrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES, kCCOptionECBMode,
                                          keyPtr, kCCKeySizeAES128,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess)
    {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

-(NSString *) decryptPrivateKey:(NSString *)encryptedPrivateKeyData withPassword:(NSString *) password
{
    
    NSString *key=password;
    
    
//    key=@"123456";
//    key=[key stringByAppendingString:@"1111"];
    if(key.length>16)
    {
        key=[key substringToIndex:16];
    }
    else if(key.length<16)
    {
        while(key.length<16)
            key=[key stringByAppendingString:@" "];
    }
    
    
    NSData *prKeyData=[self AES256DecryptData:[LWUtils dataFromHexString:encryptedPrivateKeyData] WithKey:key];
    
    char *pointer=(char *)prKeyData.bytes;
    NSString *privateWifString=[[NSString alloc] initWithData:prKeyData encoding:NSUTF8StringEncoding];
    if(privateWifString.length && pointer[prKeyData.length-1]==(char)0x0)
        privateWifString=[[NSString alloc] initWithCString:pointer encoding:NSASCIIStringEncoding];
    
    
    return [privateWifString copy];
    
//    uint8_t *string=(uint8_t *)[privateWifString cStringUsingEncoding:NSUTF8StringEncoding];
//    
//    uint8_t data[100];
//    base58_decode_check(string, data, 100);
//    NSData *privateKeyData=[[NSData alloc] initWithBytes:data+1 length:32];
//    _privateKey=[self hexStringFromData:privateKeyData];
    
    

//    [self generatePublicKeyFromPrivateKey];
    
//    NSString *str1=[self encryptKey:_privateKeyWif password:[LWKeychainManager instance].password pin:[LWKeychainManager instance].pin];

//    NSLog(@"%@", str1);

}

//-(void) decryptKeyIfPossible
//{
//    
//    NSString *password=[LWKeychainManager instance].password;
//    NSString *key=[LWKeychainManager instance].encodedPrivateKey;
//    
//    if([LWKeychainManager instance].password && [LWKeychainManager instance].encodedPrivateKey)
//    {
//        _encryptedKey=[LWKeychainManager instance].encodedPrivateKey;
//        
////        uint8_t data[100];
////        
////        base58_decode_check([_encryptedKey cStringUsingEncoding:NSUTF8StringEncoding], data, 100);
////        NSData *prKeyData=[[NSData alloc] initWithBytes:data length:32];
////        
//        
//        
//        [self decryptPrivateKey:_encryptedKey];
//    }
//}

-(BTCKey *) generateKey {
    
    NSData *privateKeyData=[self generateRandomKeyData32];
    BTCKey *key = [[BTCKey alloc] initWithPrivateKey:privateKeyData];
    key.publicKeyCompressed=YES;
    return key;
}

-(NSData *) generateRandomKeyData32 {
    uint8_t randKeyBytes[32];
    
    SecRandomCopyBytes (kSecRandomDefault, 32, randKeyBytes);
    
    NSData *privateKeyData=[[NSData alloc] initWithBytes:randKeyBytes length:32];
    
    return privateKeyData;
}

-(NSData *) generateRandomKeyData16 {
    uint8_t randKeyBytes[32];
    
    SecRandomCopyBytes (kSecRandomDefault, 16, randKeyBytes);
    
    NSData *privateKeyData=[[NSData alloc] initWithBytes:randKeyBytes length:16];
    
    return privateKeyData;
}


-(NSDictionary*) generateKeyDict
{
    BTCKey* btcKey = [self generateKey];
    NSString *wif;
    if([self isDevServer])
        wif=btcKey.WIFTestnet;
    else
        wif=btcKey.WIF;
    
    return @{@"wif": wif, @"publicKey": [LWUtils hexStringFromData:btcKey.publicKey]};
    
    
//    NSString *address=privateKeyForLykke.addressTestnet.string;;
//
//    
//    NSLog(@"GENERATED PRIVATE KEY: %@", wif);
//    
//    
//    NSLog(@"ADDRESS: %@", address);
    
//    [[LWKeychainManager instance] saveLykkePrivateKey:wif];
    
    
//
//    NSString *privateKey=[self hexStringFromData:privateKeyData];
//    
//    
////    privateKey=@"f19c523315891e6e15ae0608a35eec2e00ebd6d1984cf167f46336dabd9b2de4";//Testing from example
////    privateKeyData=[self dataFromHexString:privateKey];//Testing
//    
//    
//    _privateKey=[privateKey copy];
//    [self generatePublicKeyFromPrivateKey];
//
//    
//    NSString *str1=[self encryptKey:_privateKeyWif password:[LWKeychainManager instance].password pin:[LWKeychainManager instance].pin];
////    NSString *str1=[self encryptKey:_privateKeyWif password:@"123456" pin:@"0000"];
//    _encryptedKey=str1;
//    NSLog(@"%@", str1);
//    
//    
//    NSLog(@"Key: %@     Encrypted: %@", privateKey, _encryptedKey);
    
    
//    [self decryptPrivateKey:[_encryptedKey copy]];
//    
//    NSLog(@"Key: %@     Encrypted: %@", privateKey, _encryptedKey);

    
}


//-(void) generatePublicKeyFromPrivateKey
//{
//    NSData *privateKeyData=[self dataFromHexString:_privateKey];
//
//    BOOL flagProd=[[LWKeychainManager instance].address isEqualToString:kProductionServer] || [[LWKeychainManager instance].address isEqualToString:kStagingTestServer];
//    
//    uint8_t data[100];
//    memcpy(data+1, privateKeyData.bytes, privateKeyData.length);
//    if(flagProd)
//        data[0]=0x80;
//    else
//        data[0]=0xef;
//    
//    data[33]=0x01;
//    
//    char tmpstr[200];
//    
//    base58_encode_check(data, (uint8_t)privateKeyData.length+2, tmpstr, 200);
//    
//    _privateKeyWif=[[NSString alloc] initWithCString:tmpstr encoding:NSUTF8StringEncoding];
//    
//    
//    uint8_t pub_key[33];
//    for(int i=0;i<33;i++)
//        pub_key[i]=0x0;
//    
//    
//    ecdsa_get_public_key33(&secp256k1, privateKeyData.bytes, pub_key);
//
//    NSData *publicKeyData=[[NSData alloc] initWithBytes:pub_key length:33];
//    
//    NSString *publicKeyString=[self hexStringFromData:publicKeyData];
//    
//    
//    char pubkey_hash[21];
//    
//    ecdsa_get_pubkeyhash(pub_key, (uint8_t *)pubkey_hash+1);
//    if(flagProd)
//        pubkey_hash[0]=0x0;
//    else
//        pubkey_hash[0]=0x6f; //testnet pubkey hash prefix
//    
//    NSData *pubKeyHash=[[NSData alloc] initWithBytes:pubkey_hash length:21];
//    
//    
//    
//    //    base58_encode_check(pubKeyHash.bytes, pubKeyHash.length, tmpstr, 200);
//    
//    char address[200];
//    uint8_t version;
//    if(flagProd)
//        version=0;
//    else
//        version=0x6f;
//    ecdsa_get_address(pub_key, version, address, 200);
//    
//    NSString *bitcoinAddress=[[NSString alloc] initWithCString:address encoding:NSUTF8StringEncoding];
//    
//    
//    _publicKey=publicKeyString;
//    _bitcoinAddress=bitcoinAddress;
//    
//
//}

//-(void) signEthereumTransactions:(NSArray *) arr
//{
//    if(!arr.count || !privateKeyForLykke)
//    {
//        if(_backgroudFetchCompletionHandler)
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                _backgroudFetchCompletionHandler(UIBackgroundFetchResultNoData);
//                _backgroudFetchCompletionHandler=nil;
//            });
//        }
//        return;
//    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        ethManager=[[LWEthereumSignManager alloc] initWithEthPrivateKey:[LWUtils hexStringFromData:privateKeyForLykke.privateKey] withCompletion:^{
//        
//            numberOfSignedTransactionsSent=arr.count;
//            for(LWSignRequestModel *d in arr)
//            {
//                NSString *signature=[ethManager signHash:d.hashString];
//                d.signature=signature;
//                
////                d.requestId=@"ksjdhksjhdkjh";
////                d.address=@"snmenm";
//                [[LWAuthManager instance] requestSendSignedTransaction:d];
//                
//            }
//         }];
//         });
//}

-(void) signatureSent
{
    numberOfSignedTransactionsSent--;
    if(numberOfSignedTransactionsSent==0 && _backgroudFetchCompletionHandler)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"SIGN" message:@"Transactions signed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        _backgroudFetchCompletionHandler(UIBackgroundFetchResultNewData);
        _backgroudFetchCompletionHandler=nil;
        });
    }
}

//-(void) createETHAddressAndPubKeyWithCompletion:(void (^)(NSDictionary *))completion
//{
//    void (^block)(void)=^{
//        
//        NSDictionary *dict=[ethManager createAddressAndPubKey];
//        completion(dict);
//    };
//
//    if(ethManager)
//    {
//        block();
//    }
//    else
//    {
//        ethManager=[[LWEthereumSignManager alloc] initWithEthPrivateKey:[LWUtils hexStringFromData:privateKeyForLykke.privateKey] withCompletion:^{
//            block();
//        }];
//    }
//    
//}

-(void) logoutUser
{
    privateKeyForLykke=nil;
}

//-(void) testMethod:(NSNotification *) notification
//{
//    NSLog(@"Notification received");
//}


@end



