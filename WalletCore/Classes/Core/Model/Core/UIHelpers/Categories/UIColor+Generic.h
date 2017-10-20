//
// UIColor+Generic.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface HSBColor : NSObject {
    
}

@property (nonatomic) CGFloat hue;
@property (nonatomic) CGFloat sat;
@property (nonatomic) CGFloat bri;

@end


@interface UIColor (Generic)

@property (nonatomic, readonly) CGFloat red;
@property (nonatomic, readonly) CGFloat green;
@property (nonatomic, readonly) CGFloat blue;
@property (nonatomic, readonly) CGFloat alpha;

// brightness > 1 = more bright
// brightness < 1 = less bright
- (UIColor *) colorWithAdjustedBrightness:(CGFloat)brightness;

+ (UIColor *) colorWithR:(int)r g:(int)g b:(int)b;
+ (UIColor *) colorWithR:(int)r g:(int)g b:(int)b a:(int)a;

//
// Hex support
//

// takes 0x123456
+ (UIColor *) colorWithHex:(UInt32)col;

// takes @"123456"
+ (UIColor *) colorWithHexString:(NSString *)str;

// returns @"123456"
- (NSString *) hexString;

// returns 0x123456
- (UInt32) hex;

- (UIImage *)imageWithSize:(CGSize)size;

@end

UIColor * UIColorWithRGB(int r, int g, int b);
UIColor * UIColorWithRGBA(int r, int g, int b, int a);
