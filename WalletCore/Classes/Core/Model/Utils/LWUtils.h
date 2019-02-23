//
//  LWUtils.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 03.04.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class LWAssetPairModel;

typedef NS_ENUM(NSUInteger, LWRoundType) {
	LWRoundTypeStandard,
	LWRoundTypeToHigher,
	LWRoundTypeToLower
};


@interface LWUtils : NSObject {
    
}

+ (UIImage *)imageForIssuerId:(NSString *)issuerId;
+ (UIImage *)imageForIATAId:(NSString *)imageType;
+ (NSString *)baseAssetTitle:(LWAssetPairModel *)assetPair;
+ (NSString *)quotedAssetTitle:(LWAssetPairModel *)assetPair;
+ (NSString *)priceForAsset:(LWAssetPairModel *)assetPair forValue:(NSNumber *)value;
+ (NSString *)priceForAsset:(LWAssetPairModel *)assetPair forValue:(NSNumber *)value withFormat:(NSString *)format;

+(double) fairVolume:(double) volume accuracy:(int) accuracy roundToHigher:(BOOL) flagRoundHigher;
+ (double)fairVolume:(double)volume accuracy:(int)accuracy roundType:(LWRoundType)roundType;

+(NSString *) formatVolume:(double) volume accuracy:(int) accuracy;
+(NSString *) formatVolumeWithZeros:(double) volume accuracy:(int) accuracy;
+(NSString *) formatVolumeWithComma:(double) volume accuracy:(int) accuracy;

+(NSString *) formatFairVolume:(double) volume accuracy:(int) accuracy roundToHigher:(BOOL) flagRoundHigher;
+ (NSString *)formatFairVolume:(double)volume accuracy:(int)accuracy roundType:(LWRoundType)roundType;

+(NSString *) formatVolumeString:(NSString *) volume currencySign:(NSString *) currency accuracy:(int) accuracy removeExtraZeroes:(BOOL) flagRemoveZeroes;
+(NSString *) formatVolumeNumber:(NSNumber *) volumee currencySign:(NSString *) currency accuracy:(int) accuracy removeExtraZeroes:(BOOL) flagRemoveZeroes;

+(NSString *) addZeroesIfNeeded:(NSString *) string accuracy:(int) accuracy;

+(NSString *) stringFromDouble:(double) number;
+(NSString *) stringFromNumber:(NSNumber *) number;
+(NSNumber *) accuracyForAssetId:(NSString *) assetID;
+(NSString *) hexStringFromData:(NSData *) data;
+(NSData *) dataFromHexString:(NSString *) command;

+(void) appendToLogFile:(NSString *)string;

+(double) logarithmicValueFrom:(double) value min:(double) min max:(double) max length:(double) length; //length: длина шкалы на которую надо уместить значения от min до max
+(double) convertAmount:(double) amount fromCurrency:(NSString *)from to:(NSString *)to flagToHigher:(BOOL) flagToHigher;

+(BOOL) searchAssets:(NSString *) assets inString:(NSString *) string;

+(NSArray *) decodeLEB128:(char *) pointer length:(int) length numOfOutputs:(int) outputs;

@end
