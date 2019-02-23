//
//  LWUtils.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 03.04.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWUtils.h"
#import "LWCache.h"
#import "LWMath.h"
#import "LWAssetModel.h"
#import "LWAssetPairModel.h"
#import "LWMarginalWalletsDataManager.h"
#import "LWMarginalWalletAsset.h"

@implementation LWUtils

+ (UIImage *)imageForIssuerId:(NSString *)issuerId {
    if (issuerId) {
        if ([issuerId isEqualToString:@"BTC"]) {
            return [UIImage imageNamed:@"WalletBitcoin"];
        }
#ifdef PROJECT_IATA
        else if ([issuerId isEqualToString:@"LKE"]) {
            return [UIImage imageNamed:@"IATAWallet"];
        }        
#else
        else if ([issuerId isEqualToString:@"LKE"]) {
            return [UIImage imageNamed:@"WalletLykke"];
        }
#endif
    }
    return nil;
}

+ (UIImage *)imageForIATAId:(NSString *)imageType {
#ifdef PROJECT_IATA
    if (imageType) {
        if ([imageType isEqualToString:@"EK"]) {
            return [UIImage imageNamed:@"EmiratesIcon"];
        }
        else if ([imageType isEqualToString:@"QR"]) {
            return [UIImage imageNamed:@"QatarIcon"];
        }
        else if ([imageType isEqualToString:@"BA"]) {
            return [UIImage imageNamed:@"BritishAirwaysIcon"];
        }
        else if ([imageType isEqualToString:@"DL"]) {
            return [UIImage imageNamed:@"DeltaAirLinesIcon"];
        }
        else if ([imageType isEqualToString:@"IT"]) {
            return [UIImage imageNamed:@"IATAIcon"];
        }
        else {
            return nil;
        }
    }
    else {
        return nil;
    }
#else
    return nil;
#endif
}

+(NSNumber *) accuracyForAssetId:(NSString *) assetID
{
        NSArray *assets=[LWCache instance].allAssets;

        NSNumber *accuracy=@(0);
        for(LWAssetModel *m in assets)
        {
            if([m.identity isEqualToString:assetID])
            {
                accuracy=m.accuracy;
                break;
            }
        }
        
        return accuracy;

}

+(NSString *) stringFromDouble:(double) number
{
    if(number==(int)number)
    {
        return [NSString stringWithFormat:@"%d", (int)number];
    }
    NSString *str=[NSString stringWithFormat:@"%.8lf", number];
    while (str.length>1 )
    {
        if([[str substringFromIndex:str.length-1] isEqualToString:@"0"])
        {
            str=[str substringToIndex:str.length-1];
        }
        else
            break;
    }
    
    return str;
}

+(NSString *) stringFromNumber:(NSNumber *) number
{
    NSString *string=number.stringValue;
    string=[string stringByReplacingOccurrencesOfString:@"," withString:@"."];
    if([string rangeOfString:@"."].location==NSNotFound)
        return string;
    NSArray *arr=[string componentsSeparatedByString:@"."];
    if([arr[1] length]>8)
    {
        string=[NSString stringWithFormat:@"%@.%@", arr[0], [arr[1] substringToIndex:8]];
    }
    
    while(string.length>1)
    {
        if([[string substringFromIndex:string.length-1] isEqualToString:@"0"] || [[string substringFromIndex:string.length-1] isEqualToString:@"."])
        {
            string=[string substringToIndex:string.length-1];
        }
        else
            break;

    }
    return string;
}

+ (double)fairVolume:(double)volume accuracy:(int)accuracy roundToHigher:(BOOL)flagRoundHigher {
	return [self fairVolume:volume accuracy:accuracy roundType:flagRoundHigher ? LWRoundTypeToHigher : LWRoundTypeToLower];
}

+ (double)fairVolume:(double)volume accuracy:(int)accuracy roundType:(LWRoundType)roundType {
	NSString *formatString = [NSString stringWithFormat:@"%%.%dlf", accuracy];
	NSString *tmpStr = [NSString stringWithFormat:formatString, volume];
	
	double append = 1;
	int acc = accuracy + 2;
	while (acc > 0)	{
		append = append/10;
		acc--;
	}
	
	if ((tmpStr.doubleValue > volume-append && roundType == LWRoundTypeToHigher) ||
		(tmpStr.doubleValue < volume+append && roundType == LWRoundTypeToLower) ||
		tmpStr.doubleValue == volume) {
		return tmpStr.doubleValue;
	}
	
	append = 1;
	acc = accuracy;
	while (acc > 0)	{
		append = append/10;
		acc--;
	}
	
	if (roundType == LWRoundTypeToHigher) {
		volume = tmpStr.doubleValue + append;
	}
	else if (roundType == LWRoundTypeToHigher) {
		volume = tmpStr.doubleValue - append;
	}
	else {
		volume = tmpStr.doubleValue;
	}
	
	return volume;
}

+(NSString *) formatVolume:(double) volume accuracy:(int) accuracy
{
    NSString *str=[LWUtils formatFairVolume:volume accuracy:accuracy roundToHigher:NO];
    return  [str stringByReplacingOccurrencesOfString:@" " withString:@""];
//    return  [str stringByReplacingOccurrencesOfString:@" " withString:@","];

}

+(NSString *) formatVolumeWithComma:(double) volume accuracy:(int) accuracy
{
    NSString *str=[LWUtils formatFairVolume:volume accuracy:accuracy roundToHigher:NO];
    return  [str stringByReplacingOccurrencesOfString:@" " withString:@","];
    //    return  [str stringByReplacingOccurrencesOfString:@" " withString:@","];
    
}


+(NSString *) formatVolumeWithZeros:(double)volume accuracy:(int)accuracy {
    NSString *str = [LWUtils formatVolume:volume accuracy:accuracy];
    return [LWUtils addZeroesIfNeeded:str accuracy:accuracy];
}

+ (NSString *) formatFairVolume:(double) volume accuracy:(int) accuracy roundToHigher:(BOOL) flagRoundHigher {
	return [self formatFairVolume:volume accuracy:accuracy roundType:flagRoundHigher ? LWRoundTypeToHigher : LWRoundTypeToLower];
}

+ (NSString *)formatFairVolume:(double)volume accuracy:(int)accuracy roundType:(LWRoundType)roundType {
	double fairVolume =
//	roundType == LWRoundTypeStandard
//										? volume // "%.{acc}%dlf" will round it with usual math rules
										 [LWUtils fairVolume:volume accuracy:accuracy roundType:roundType];
	NSString *formatString = [NSString stringWithFormat:@"%%.%dlf", accuracy];
	NSString *tmpStr = [NSString stringWithFormat:formatString, fairVolume];
	
	return [LWUtils formatVolumeString:tmpStr currencySign:@"" accuracy:accuracy removeExtraZeroes:YES];
}

+(NSString *) formatVolumeNumber:(NSNumber *) volumee currencySign:(NSString *) currency accuracy:(int) accuracy removeExtraZeroes:(BOOL) flagRemoveZeroes
{
    NSString *formatString=[NSString stringWithFormat:@"%d",accuracy];
    formatString=[[@"%." stringByAppendingString:formatString] stringByAppendingString:@"lf"];
    NSString *volume=[NSString stringWithFormat:formatString,volumee.doubleValue];
    return [LWUtils formatVolumeString:volume currencySign:currency accuracy:accuracy removeExtraZeroes:flagRemoveZeroes];
}

+(NSString *) formatVolumeString:(NSString *) volumee currencySign:(NSString *) currency accuracy:(int) accuracy removeExtraZeroes:(BOOL) flagRemoveZeroes
{
    if(!currency)
        currency=@"";
    NSString *volume=[volumee stringByReplacingOccurrencesOfString:@" " withString:@""];
    double v=volume.doubleValue;
    long leftPart=labs((long)v);
    
    long rightPart=0;

    NSString *rightPartString;
    
    volume=[volume stringByReplacingOccurrencesOfString:@"," withString:@"."];

    NSArray *arr=[volume componentsSeparatedByString:@"."];
    if(arr.count==2)
    {
        rightPart=[arr[1] intValue];
        rightPartString=arr[1];
    }
    
    NSMutableArray *components=[[NSMutableArray alloc] init];
    
    while(leftPart>=1000)
    {
        long part=leftPart%1000;
        if(part<10)
            [components insertObject:[NSString stringWithFormat:@"00%ld",part] atIndex:0];
        else if(part<100)
            [components insertObject:[NSString stringWithFormat:@"0%ld",part] atIndex:0];
        else
            [components insertObject:[NSString stringWithFormat:@"%ld",part] atIndex:0];
        leftPart=leftPart/1000;
    }
    
    [components insertObject:[NSString stringWithFormat:@"%ld",leftPart] atIndex:0];
    NSMutableString *finalString=[@"" mutableCopy];
    
    if(v<0)
        [finalString appendString:@"-"];
    [finalString appendString:currency];
    if(currency.length > 0) {
        [finalString appendString:@" "];
    }
    for(int i=0;i<components.count;i++)
    {
        if(i!=0)
            [finalString appendString:@" "];
        [finalString appendString:components[i]];
    }
    if(rightPart>0 && accuracy!=0 && flagRemoveZeroes==YES)
    {
        
        NSString *toAdd=[NSString stringWithFormat:@".%@", arr[1]];
        if(accuracy>0)
        {
            if(toAdd.length>accuracy+1)
                toAdd=[toAdd substringToIndex:accuracy+1];
            
            while (toAdd.length>1 )
            {
                if([[toAdd substringFromIndex:toAdd.length-1] isEqualToString:@"0"])
                {
                    toAdd=[toAdd substringToIndex:toAdd.length-1];
                }
                else
                    break;
            }
        }
        if(toAdd.length>1)
            [finalString appendString:toAdd];
    }
    else if(rightPartString && flagRemoveZeroes==NO)
    {
        [finalString appendFormat:@".%@", rightPartString];
    }
    
    return finalString;
}

+ (NSString *)baseAssetTitle:(LWAssetPairModel *)assetPair {
    
    return [LWAssetModel assetByIdentity:assetPair.baseAssetId fromList:[LWCache instance].allAssets];
}

+ (NSString *)quotedAssetTitle:(LWAssetPairModel *)assetPair {
    return [LWAssetModel assetByIdentity:assetPair.quotingAssetId fromList:[LWCache instance].allAssets];
}

+ (NSString *)priceForAsset:(LWAssetPairModel *)assetPair forValue:(NSNumber *)value {
    //Andrey
    
//    NSString *result=[LWUtils formatVolumeString:[NSString stringWithFormat:@"%f", value.floatValue] currencySign:assetPair. accuracy:<#(int)#>]
    
    NSString *result;
    if(assetPair.inverted==NO)
    {
        result=[LWUtils formatVolumeNumber:value currencySign:@"" accuracy:assetPair.accuracy.intValue removeExtraZeroes:YES];
    }
    else
    {
        result=[LWUtils formatVolumeNumber:value currencySign:@"" accuracy:assetPair.invertedAccuracy.intValue removeExtraZeroes:YES];
    }
    
    
//    NSString *result = [LWMath priceString:value
//                                 precision:assetPair.accuracy
//                                withPrefix:@""];
    return result;
}

+ (NSString *)priceForAsset:(LWAssetPairModel *)assetPair forValue:(NSNumber *)value withFormat:(NSString *)format {
    
    NSString *rateString = [LWUtils priceForAsset:assetPair forValue:value];
    NSString *result = [NSString stringWithFormat:format,
                        [LWUtils baseAssetTitle:assetPair],
                        [LWUtils quotedAssetTitle:assetPair], rateString];
    
    
    
    result=[NSString stringWithFormat:@"%@ %@ %@ %@", format, Localize(@"exchange.spot.button.atprice"), [LWCache displayIdForAssetId:assetPair.quotingAssetId], rateString];
    
    return result;
}


+(NSString *) hexStringFromData:(NSData *) data
{
    NSUInteger capacity = data.length * 2;
    NSMutableString *string = [NSMutableString stringWithCapacity:capacity];
    const unsigned char *buf = data.bytes;
    NSInteger i;
    for (i=0; i<data.length; ++i) {
        [string appendFormat:@"%02x", (NSUInteger)buf[i]];
    }
    return string;
}

+(NSData *) dataFromHexString:(NSString *) command
{
    
    command = [command stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableData *commandToSend= [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [command length]/2; i++) {
        byte_chars[0] = [command characterAtIndex:i*2];
        byte_chars[1] = [command characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [commandToSend appendBytes:&whole_byte length:1];
    }
    
    return commandToSend;
}

+(void) appendToLogFile:(NSString *)string
{
//    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDir = [documentPaths objectAtIndex:0];
//    NSString *logPath = [[NSString alloc] initWithFormat:@"%@",[documentsDir stringByAppendingPathComponent:@"log.txt"]];
//    if([[NSFileManager defaultManager] fileExistsAtPath:logPath]==NO)
//    {
//        [[NSFileManager defaultManager] createFileAtPath:logPath contents:[NSData data] attributes:nil];
//    }
//    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:logPath];
//    [fileHandler seekToEndOfFile];
//
//
//    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//
//
//    NSString *toAppend=[NSString stringWithFormat:@"%@  %@\n",[formatter stringFromDate:[NSDate date]], string];
//
//
//    [fileHandler writeData:[toAppend dataUsingEncoding:NSUTF8StringEncoding]];
//    [fileHandler closeFile];
}


+(double) logarithmicValueFrom:(double)value min:(double)min max:(double)max length:(double)length
{
    
    //http://stackoverflow.com/questions/846221/logarithmic-slider?tab=oldest#tab-top

    double minp = 0;
    double maxp = length;
    
    // The result should be between 100 an 10000000
    double minv = log(min);//Math.log(100);
    double maxv = log(max);
    
    // calculate adjustment factor
    double scale = (maxv-minv) / (maxp-minp);
    
    
    return (log(value)-minv) / scale + minp;
}


+(NSString *) addZeroesIfNeeded:(NSString *) string accuracy:(int) accuracy
{
    if(accuracy==0)
        return string;
    NSArray *arr=[string componentsSeparatedByString:@"."];
    NSMutableString *right;
    if(arr.count==1)
        right=[[NSMutableString alloc] initWithString:@""];
    else
        right=[[NSMutableString alloc] initWithString:arr[1]];
    while (right.length<accuracy) {
        [right appendString:@"0"];
    }
    return [arr[0] stringByAppendingFormat:@".%@", right];
}

+(double) convertAmount:(double) amount fromCurrency:(NSString *)from to:(NSString *)to flagToHigher:(BOOL)flagToHigher
{
    if([from isEqualToString:to])
        return amount;
    double final=0;
	
	NSArray *allAssets = [LWMarginalWalletsDataManager shared].allAssets.copy;
    for(LWMarginalWalletAsset *asset in allAssets)
    {
        if([asset.baseAssetId isEqualToString:from] && [asset.quotingAssetId isEqualToString:to])
        {
            if(flagToHigher==NO)
                final=amount*asset.rate.bid;
            else
                final=amount*asset.rate.ask;
        }
        if([asset.baseAssetId isEqualToString:to] && [asset.quotingAssetId isEqualToString:from])
        {
            if(flagToHigher==NO)
                final=amount/asset.rate.ask;
            else
                final=amount/asset.rate.bid;

        }
    }
    
    return final;
    
}

+(BOOL) searchAssets:(NSString *)assets inString:(NSString *)string {
    if(assets.length == 0) {
        return NO;
    }
    assets = [assets uppercaseString];
    string = [string uppercaseString];
    assets = [assets stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *components = [assets componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/\\-=.,|@!#$%^&*~;:? "]];
    
    NSArray *existingAssets = [string componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/\\"]];
    if(components.count>2) {
        return NO;
    }
    if(components.count == 2 && [components[1] length] == 0) {
        components = @[components[0]];
    }
    
//    if(components.count == 1 && assets.length > 3) {
//        components = @[[assets substringToIndex:3], [assets substringFromIndex:3]];
//    }
    
    if(components.count == 1) {
        if([existingAssets[0] rangeOfString:components[0]].location != NSNotFound) {
            return YES;
        }
        if(existingAssets.count == 2) {
            if([existingAssets[1] rangeOfString:components[0]].location != NSNotFound) {
                return YES;
            }
        }
        return NO;
    }
    
    if(components.count == 2 && existingAssets.count == 2) {
        if(([existingAssets[0] rangeOfString:components[0]].location != NSNotFound && [existingAssets[1] rangeOfString:components[1]].location != NSNotFound)
           || ([existingAssets[0] rangeOfString:components[1]].location != NSNotFound && [existingAssets[1] rangeOfString:components[0]].location != NSNotFound)) {
            return YES;
        }
        
    }
    
    return NO;
    
//    NSArray *bySpace = [assets componentsSeparatedByString:@" "];
//    if(bySpace.count > 2) {
//        return NO;
//    }
//    if(bySpace.count == 1) {
//        return [string rangeOfString:assets].location != NSNotFound;
//    }
//    NSArray *bySlash = [string componentsSeparatedByString:@"/"];
//    if(bySlash.count < 2) {
//        return NO;
//    }
//    return [bySlash[0] rangeOfString:bySpace[0]].location != NSNotFound && [bySlash[1] rangeOfString:bySpace[1]].location != NSNotFound;
}


+(NSArray *) decodeLEB128:(char *) pointer length:(int) length numOfOutputs:(int) outputs {
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    uint32_t result = 0;
    int shift = 0;
    int p = 0;
    while(1) {
        char c = pointer[p];
        result |= (((uint32_t)c & 0x7F) << shift);
        if(c >> 7 == 0) {
            [arr addObject:@(result)];
            if(arr.count == outputs) {
                break;
            }
            shift = 0;
            result = 0;
        }
        else {
            shift += 7;
        }
        p++;
        if(p>length-1) {
            break;
        }
    }
    
    return arr;
    
//    var result: UInt = 0
//    var shift: UInt = 0
//    
//    while true {
//        let byte = input.read()
//        result |= ((UInt(byte) & 0x7F) << shift)
//        
//        if (byte >> 7) == 0 {
//            break
//        }
//        shift += 7
//    }
//    return result
    
    
    
}



@end
