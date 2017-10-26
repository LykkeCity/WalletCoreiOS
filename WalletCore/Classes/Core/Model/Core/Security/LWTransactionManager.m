//
//  LWTransactionManager.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 03/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWTransactionManager.h"
#import <CoreBitcoin/BTCKey.h>
#import <CoreBitcoin/BTCTransaction.h>
#import <CoreBitcoin/BTCTransactionInput.h>
#import <CoreBitcoin/BTCTransactionOutput.h>
#import "LWPKTransferModel.h"
#import "LWUtils.h"
#import <CoreBitcoin/BTCScript.h>
#import <CoreBitcoin/BTCAddress.h>
#import <CoreBitcoin/BTCData.h>
#import "LWPrivateKeyManager.h"
#import "LWKeychainManager.h"
#import "LWAuthManager.h"
#import "LWPacketCheckPendingActions.h"
#import "LWPacketGetUnsignedSPOTTransactions.h"
#import "LWOffchainTransactionsManager.h"
#import "LWPacketAccountExist.h"


@interface LWTransactionManager() <LWAuthManagerDelegate>
{
    NSTimer *timer;
    int numOfPerformigActions;
    NSTimeInterval timeFromLastCheck;
}


@end

@implementation LWTransactionManager

-(id) init {
    self = [super init];
    numOfPerformigActions = 0;
    timeFromLastCheck = 0;
//    timer = [NSTimer timerWithTimeInterval:30 target:self selector:@selector(checkForPendingActions) userInfo:nil repeats:true];
//    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
    return self;
}

+ (instancetype)shared
{
    static LWTransactionManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[LWTransactionManager alloc] init];
    });
    return shared;
}

-(void) startAction {
    if(_backgroudFetchCompletionHandler != nil) {
        numOfPerformigActions++;
    }
}

-(void) endAction {
    if(_backgroudFetchCompletionHandler != nil) {
        numOfPerformigActions--;
        if(numOfPerformigActions <= 0) {
            numOfPerformigActions = 0;
            _backgroudFetchCompletionHandler(UIBackgroundFetchResultNewData);
            _backgroudFetchCompletionHandler = nil;
        }
    }
}

-(void) checkForPendingActions {
    if(_backgroudFetchCompletionHandler != nil) {
        if([NSDate timeIntervalSinceReferenceDate] - timeFromLastCheck < 28) {
            return;
        }
        numOfPerformigActions = 0;
        _backgroudFetchCompletionHandler(UIBackgroundFetchResultFailed);
        _backgroudFetchCompletionHandler = nil;
        return;
    }
    timeFromLastCheck = [NSDate timeIntervalSinceReferenceDate];
    if([LWKeychainManager instance].isAuthenticated) {
        [LWAuthManager instance].caller = self;
        [[LWAuthManager instance] requestCheckPendingActions];
    }
}

-(void) authManagerDidCheckPendingActions:(LWPacketCheckPendingActions *)packet {
    
    
    if(packet.needReinit) {
        if([LWKeychainManager instance].isAuthenticated) {
                [LWAuthManager instance].caller = self;
                [[LWAuthManager instance] requestEmailValidation:[LWKeychainManager instance].login];
        }
    }
    
    if(packet.hasUnsignedTransactions == NO && packet.hasOffchainRequests == NO && _backgroudFetchCompletionHandler != nil) {
        _backgroudFetchCompletionHandler(UIBackgroundFetchResultNoData);
        _backgroudFetchCompletionHandler=nil;
        numOfPerformigActions = 0;
        return;
    }

    if(packet.hasUnsignedTransactions) {
        [self startAction];
        [LWAuthManager instance].caller = self;
        [[LWAuthManager instance] requestGetUnsignedSPOTTransactions];
    }
    
    if(packet.hasOffchainRequests) {
        [self startAction];
        [[LWOffchainTransactionsManager shared] getRequests];
    }
}

-(void) authManager:(LWAuthManager *)manager didCheckRegistration:(LWPacketAccountExist *)packet {
    [packet saveValues];
}

-(void) authManagerDidGetUnsignedSPOTTransactions:(LWPacketGetUnsignedSPOTTransactions *)packet {
    NSString *keyWif = [LWPrivateKeyManager shared].wifPrivateKeyLykke;
    if(keyWif) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
    for(NSDictionary *d in packet.transactions) {
        BTCTransaction *transaction = [LWTransactionManager signMultiSigTransaction:d[@"Hex"] withKey:keyWif];
        if(transaction) {
            [arr addObject:@{@"Hex":[LWUtils hexStringFromData:transaction.data], @"Id":d[@"Id"]}];
        }
    }
    if([arr count]) {
        [LWAuthManager instance].caller = self;
        [[LWAuthManager instance] requestSendSignedSPOTTransactions:arr];
    }
    }
    
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self endAction];
        });
    
}



+(BTCTransaction *) signMultiSigTransaction:(NSString *)_transaction withKey:(NSString *)privateKey
{
    BTCTransaction *transaction=[[BTCTransaction alloc] initWithHex:_transaction];
    
    if(!transaction)
        return nil;
    BTCKey *key=[[BTCKey alloc] initWithWIF:privateKey];
    NSData *pubKey = key.publicKey;
    
    NSString *sss = [LWUtils hexStringFromData:key.publicKey];
    
    if(!key)
        return nil;
    if(transaction.inputs.count==0)
        return nil;
    
    for(BTCTransactionInput *input in transaction.inputs)
    {
            BTCSignatureHashType hashtype = BTCSignatureHashTypeAll;
            
            NSArray *chunks=input.signatureScript.scriptChunks;
        
            if(!chunks || chunks.count!=4 || [[chunks[3] pushdata] rangeOfData:pubKey options:0 range:NSMakeRange(0, [[chunks[3] pushdata] length])].location == NSNotFound)
                continue;
            
            BTCScript *tempSigScript=[[BTCScript alloc] initWithData:[chunks[3] pushdata]];
            
            NSData* hash = [transaction signatureHashForScript:tempSigScript inputIndex:(uint32_t)[transaction.inputs indexOfObject:input] hashType:hashtype error:NULL];
            
            if(!hash)
                return nil;

            
            NSData *signature=[key signatureForHash:hash hashType:SIGHASH_ALL];
        if(!signature)
            return nil;
        
        
            BTCScript *newScript=[[BTCScript alloc] init];
            [newScript appendOpcode:OP_0];
            [newScript appendData:signature];
        if([[chunks[2] pushdata] length]) {
            [newScript appendData:[chunks[2] pushdata]];
        }
        else {
            char z = 0x0;
            [newScript appendData:[NSData dataWithBytes:&z length:1]];
        }

            [newScript appendData:[chunks[3] pushdata]];
            
            input.signatureScript=newScript;
        
    }
    
    
    
    NSString *transactiondata=[LWUtils hexStringFromData:transaction.data];
    NSLog(@"%@", transactiondata);
    
    
    
    return transaction;
    
}


+(NSString *) signOffchainTransaction:(NSString *)_transaction withKey:(NSString *)privateKey type:(OffchainTransactionType)type
{
    if(type == OffchainTransactionTypeCashIn) {
        _transaction = [LWTransactionManager signTransactionRaw:_transaction key:privateKey];
        privateKey = [LWPrivateKeyManager shared].wifPrivateKeyLykke;
        
    }
    BTCTransaction *transaction=[[BTCTransaction alloc] initWithHex:_transaction];
    
    if(!transaction)
        return nil;
    
    BTCKey *key=[[BTCKey alloc] initWithWIF:privateKey];
    NSData *pubKey = key.publicKey;
    
    if(!key)
        return nil;
    if(transaction.inputs.count==0)
        return nil;
    
    BTCSignatureHashType hashtype;
    if(type == OffchainTransactionTypeCreateChannel || type == OffchainTransactionTypeCashIn) {
        hashtype = BTCSignatureHashTypeAll;
    }
    else {
        hashtype = BTCSignatureHashTypeAnyoneCanPay | BTCSignatureHashTypeAll;
    }

    for(BTCTransactionInput *input in transaction.inputs)
    {
        NSArray *chunks=input.signatureScript.scriptChunks;
        
        if(!chunks || chunks.count!=4 || [[chunks[3] pushdata] rangeOfData:pubKey options:0 range:NSMakeRange(0, [[chunks[3] pushdata] length])].location == NSNotFound)
            continue;
        
        BTCScript *tempSigScript=[[BTCScript alloc] initWithData:[chunks[3] pushdata]];
        
        NSData* hash = [transaction signatureHashForScript:tempSigScript inputIndex:(uint32_t)[transaction.inputs indexOfObject:input] hashType:hashtype error:NULL];
        
        if(!hash)
            return nil;
        
        
        NSData *signature=[key signatureForHash:hash hashType:hashtype];
        if(!signature)
            return nil;
        
        BTCScript *newScript=[[BTCScript alloc] init];
        [newScript appendOpcode:OP_0];
        [newScript appendData:signature];

        if([[chunks[2] pushdata] length]) {
            [newScript appendData:[chunks[2] pushdata]];
        }
        else {
            char z = 0x0;
            [newScript appendData:[NSData dataWithBytes:&z length:1]];
        }
        
        [newScript appendData:[chunks[3] pushdata]];
        input.signatureScript=newScript;
    }
    
    
    
    NSString *transactiondata=[LWUtils hexStringFromData:transaction.data];
    NSLog(@"%@", transactiondata);
    
    
    
    return transactiondata;
    
}


+(NSString *) signTransactionRaw:(NSString *) rawString key:(NSString *)_key
{
    
    BTCTransaction *transaction=[[BTCTransaction alloc] initWithHex:rawString];
    
     BTCKey *key=[[BTCKey alloc] initWithWIF:_key];
    for(BTCTransactionInput *input in transaction.inputs)
    {
        BTCScript *signature=input.signatureScript;
        if(signature.hex.length==0) //Need to sign
        {
            BTCScript* p2cpkhScript = [[BTCScript alloc] initWithAddress:[BTCPublicKeyAddress addressWithData:BTCHash160(key.compressedPublicKey)]];
            NSData *hash=[transaction signatureHashForScript:[p2cpkhScript copy] inputIndex:(uint32_t)[transaction.inputs indexOfObject:input] hashType:SIGHASH_ALL error:nil];
            NSData *signature=[key signatureForHash:hash hashType:SIGHASH_ALL];
            
            BTCScript *newScript=[[BTCScript alloc] init];
            
            NSData *pubKey=key.publicKey;
            [newScript appendData:signature];
            [newScript appendData:pubKey];
            input.signatureScript=newScript;
        }
    }
    

    
    NSString *transactiondata=[LWUtils hexStringFromData:transaction.data];
    NSLog(@"%@", transactiondata);
    
    return transactiondata;
}










+(void) testSign:(NSString *)_transaction {
    BTCTransaction *transaction=[[BTCTransaction alloc] initWithHex:_transaction];
    
    if(!transaction)
        return;
    //    BTCKey *key=[[BTCKey alloc] initWithWIF:@"cNTXye9kVVnKegjkngGm6DPauM7NACNJd3K93SgeucMCemuRANux"];//cNj3wXLNcr5fMtWcqaFgLGBBi9qiEGKYrwr2dcP2QnNSrugxiJEL
//    BTCKey *key=[[BTCKey alloc] initWithWIF:@"cNTXye9kVVnKegjkngGm6DPauM7NACNJd3K93SgeucMCemuRANux"];
    
    NSArray *outputs = transaction.outputs;
    
    for(BTCTransactionOutput *o in outputs) {
        
        BTCScript *script = o.script;
        
   //     BTCAddress *addrr = [BTCAddress addressWithData:<#(nullable NSData *)#>
        
        BTCAddress *addr = script.standardAddress;
        BOOL ddd = addr.isTestnet;
        NSString *string = addr.string;
        
        BTCPublicKeyAddressTestnet *tn = [BTCPublicKeyAddressTestnet addressWithData:addr.data];
        NSString *tns = tn.string;
        
         NSData *data = o.data;
        if(data.length < 17){
            continue;
        }
        char *c = data.bytes;
        if(c[9] == 0x6a && c[11] == 0x4f && c[12] == 0x41) {
            NSArray *vals = [LWUtils decodeLEB128:c+16 length:data.length - 16 numOfOutputs:(int)c[15]];
            NSLog(@"%@", vals);
        }
    }
    

}




@end
