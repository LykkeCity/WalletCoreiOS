//
// UIColor+Generic.m
//

#import "UIColor+Generic.h"


@implementation UIColor (Generic)

- (CGColorSpaceModel) colorSpaceModel
{
    return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

- (CGFloat) red
{
    if ([self colorSpaceModel] == kCGColorSpaceModelMonochrome) {
        const CGFloat *c = CGColorGetComponents(self.CGColor);
        return c[0];
    }

    const CGFloat *c = CGColorGetComponents(self.CGColor);
    return c[0];
}

- (CGFloat) green
{
    if ([self colorSpaceModel] == kCGColorSpaceModelMonochrome) {
        const CGFloat *c = CGColorGetComponents(self.CGColor);
        return c[0];
    }

    const CGFloat *c = CGColorGetComponents(self.CGColor);
    return c[1];
}

- (CGFloat) blue
{
    if ([self colorSpaceModel] == kCGColorSpaceModelMonochrome) {
        const CGFloat *c = CGColorGetComponents(self.CGColor);
        return c[0];
    }

    const CGFloat *c = CGColorGetComponents(self.CGColor);
    return c[2];
}

- (CGFloat) alpha
{
    return CGColorGetAlpha(self.CGColor);
}

- (UIColor *) colorWithAdjustedBrightness:(CGFloat)brightnessDelta
{
    CGFloat hue, saturation, brightness, alpha;
    if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        brightness += (brightnessDelta - 1);
        brightness = MAX(MIN(brightness, 1.0), 0.0);
        return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    }

    CGFloat white;
    if ([self getWhite:&white alpha:&alpha]) {
        white += (brightnessDelta - 1);
        white = MAX(MIN(white, 1.0), 0.0);
        return [UIColor colorWithWhite:white alpha:alpha];
    }

    return self;
}

+ (UIColor *) colorWithR:(int)r g:(int)g b:(int)b
{
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1];
}

+ (UIColor *) colorWithR:(int)r g:(int)g b:(int)b a:(int)a
{
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a/255.0f];
}

+ (UIColor *)colorWithHexString:(NSString *)hexadecimal
{
    // convert Objective-C NSString to C string
	const char *cString = [hexadecimal cStringUsingEncoding: NSASCIIStringEncoding];
    
	// Strip optional #
	if (cString[0] == '#') cString++;
    
	// Validate is hex string
	for (const char *charPtr = cString; *charPtr != 0; charPtr++)
	{
		char ch = *charPtr;
		BOOL isHexDigit = (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f') || (ch >= 'A' && ch <= 'F');
		if ( !isHexDigit ) return nil;
        if ( charPtr - cString > 8 ) return nil; // aaRRGGBB is largest string we accept.
	}
    
	// Make canonical hex string
	char canonicalARGB[8 + 1];  // null terminated
	canonicalARGB[8] = 0;
	switch (strlen(cString))
	{
		case 3:
			canonicalARGB[0] = canonicalARGB[1] = 'F'; // Alpha
			for (int i = 0; i < 6; i++)
			{
				canonicalARGB[i + 2] = cString[i / 2];
			}
			break;
		case 4:
			for (int i = 0; i < 8; i++)
			{
				canonicalARGB[i] = cString[i / 2];
			}
			break;
		case 6:
			canonicalARGB[0] = canonicalARGB[1] = 'F'; // Alpha
			strcpy(canonicalARGB + 2, cString);
			break;
		case 8:
			strcpy(canonicalARGB, cString);
			break;
		default:
			return nil;
	}
    
	long long int hex = strtoll(canonicalARGB, NULL , 16 );
    
	CGFloat alpha = (CGFloat)((hex & 0xFF000000) >> 24) / 255.f;
	CGFloat red = (CGFloat)((hex & 0x00FF0000) >> 16) / 255.f;
	CGFloat green = (CGFloat)((hex & 0x0000FF00) >> 8) / 255.f;
	CGFloat blue = (CGFloat)((hex & 0x000000FF) >> 0) / 255.f;
    
	UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
	return color;
}

+ (UIColor *)colorWithHex:(UInt32)hexadecimal
{
    CGFloat red, green, blue, alpha = 1.0f;
	NSString *hexString = [NSString stringWithFormat: @"%03X" , (unsigned int)hexadecimal];
    
	if ( hexString.length == 3 )
	{
		// bitwise AND operation
		// hexadecimal's first 2 values
		red = (CGFloat)(( hexadecimal >> 8 ) & 0xF ) / 15.0f;
		// hexadecimal's third and fourth values
		green = (CGFloat)(( hexadecimal >> 4 ) & 0xF ) / 15.0f;
		// hexadecimal's fifth and sixth values
		blue = (CGFloat)( hexadecimal & 0xF ) / 15.0f;
	}
	else if ( hexString.length == 4 )
	{
		// bitwise AND operation
		// hexadecimal's first 2 values
		alpha = (CGFloat)(( hexadecimal >> 12 ) & 0xF ) / 15.0f;
		// hexadecimal's third and fourth values
		red = (CGFloat)(( hexadecimal >> 8 ) & 0xF ) / 15.0f;
		// hexadecimal's fifth and sixth values
		green = (CGFloat)(( hexadecimal >> 4 ) & 0xF ) / 15.0f;
		// hexadecimal's seventh and eighth
		blue = (CGFloat)( hexadecimal & 0xF ) / 15.0f;
	}
	else if ( hexString.length == 6 )
	{
		// bitwise AND operation
		// hexadecimal's first 2 values
		red = (CGFloat)(( hexadecimal >> 16 ) & 0xFF ) / 255.0f;
		// hexadecimal's third and fourth values
		green = (CGFloat)(( hexadecimal >> 8 ) & 0xFF ) / 255.0f;
		// hexadecimal's fifth and sixth values
		blue = (CGFloat)( hexadecimal & 0xFF ) / 255.0f;
	}
	else if ( hexString.length == 8 )
	{
		// bitwise AND operation
		// hexadecimal's first 2 values
		alpha = (CGFloat)(( hexadecimal >> 24 ) & 0xFF ) / 255.0f;
		// hexadecimal's third and fourth values
		red = (CGFloat)(( hexadecimal >> 16 ) & 0xFF ) / 255.0f;
		// hexadecimal's fifth and sixth values
		green = (CGFloat)(( hexadecimal >> 8 ) & 0xFF ) / 255.0f;
		// hexadecimal's seventh and eighth
		blue = (CGFloat)( hexadecimal & 0xFF ) / 255.0f;
	}
	else
	{
		return nil;
	}
    
	UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
	return color;
}

- (NSString *) hexString
{
//    return [NSString stringWithFormat:@"%06lx", [self hex]];
    return [self hexStringFromColor:self withHash:YES];
}

- (NSString *)hexStringFromColor:(UIColor *)color withHash:(BOOL)withHash
{
	// get the color components of the color
	const NSUInteger totalComponents = CGColorGetNumberOfComponents( [color CGColor] );
	const CGFloat *components = CGColorGetComponents( [color CGColor] );
	NSString *hexadecimal = nil;
	NSString *hash = withHash? @"#" : @"";
    
	// some cases, totalComponents will only have 2 components
	// such as black, white, gray, etc..
	// multiply it by 255 and display the result using an uppercase
	// hexadecimal specifier (%X) with a character length of 2
	switch ( totalComponents )
	{
		case 4 :
			hexadecimal = [NSString stringWithFormat: @"%@%02X%02X%02X" , hash , (int)(255 * components[0]) , (int)(255 * components[1]) , (int)(255 * components[2])];
			break;
            
		case 2 :
			hexadecimal = [NSString stringWithFormat: @"%@%02X%02X%02X" , hash , (int)(255 * components[0]) , (int)(255 * components[0]) , (int)(255 * components[0])];
			break;
            
		default:
			break;
	}
    
	return hexadecimal;
}

- (UInt32) hex
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    UInt32 hex = 0;
    
    CGColorSpaceModel colorModel = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
    
    if (colorModel == kCGColorSpaceModelMonochrome)
    {
        UInt32 brightness = components[0]*255;
        hex = brightness * 0x10000 + brightness * 0x100 + brightness;
    }
    else if (colorModel == kCGColorSpaceModelRGB)
    {
        UInt32 r = components[0]*255;
        UInt32 g = components[1]*255;
        UInt32 b = components[2]*255;
        
        hex = r * 0x10000 + g * 0x100 + b;
    } else {
        NSLog(@"Unknown colorSpaceModel for %@",self);
        hex = 0;
    }
                                                        
    
    return hex;
}

- (UIImage *)imageWithSize:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

UIColor * UIColorWithRGB(int r, int g, int b)
{
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1];
}

UIColor * UIColorWithRGBA(int r, int g, int b, int a)
{
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a/255.0f];
}
