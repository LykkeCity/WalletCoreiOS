//
//  TradingLinearGraphViewTest.m
//  ModernWallet
//
//  Created by Andrey Snetkov on 13/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "TradingLinearGraphViewTest.h"

@interface TradingLinearGraphViewTest()
{
    CGFloat minGraphY;
    CGFloat maxGraphY;
    float coeff;
    float minValue;
    float maxValue;
    UIImageView *yellowDot;
    UIImageView *purpleDot;
    
    float minAsk;
    float maxBid;
    float minTopGraphPoint;
    float maxBottomGraphPoint;
    
}
@end

@implementation TradingLinearGraphViewTest

-(void) awakeFromNib
{
    [super awakeFromNib];
    yellowDot=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 4, 4)];
    yellowDot.image=[UIImage imageNamed:@"LinearGraphDotYellowNew"];
    [self addSubview:yellowDot];

    purpleDot=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 4, 4)];
    purpleDot.image=[UIImage imageNamed:@"LinearGraphDotYellowNew"];
    [self addSubview:purpleDot];
    yellowDot.hidden=YES;
    purpleDot.hidden=YES;
    
    

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setOpaque:NO];
    }
    
    return self;
}

-(void) setChanges:(NSArray *)changes
{
    
//    NSMutableArray *nnnn=[[NSMutableArray alloc] init];
//    for(int i=0;i<changes.count;i++)
//    {
//        NSMutableDictionary *d=[changes[i] mutableCopy];
//        if(i<changes.count)
//        {
//            d[@"Bid"]=@(0);
//        }
//        [nnnn addObject:d];
//    }
    
    _changes=changes;
    
//    _changes=nnnn;
    minGraphY=80;
    
//    if([UIScreen mainScreen].bounds.size.width==320)
//    {
//        minGraphY=55;
//        maxGraphY=self.bounds.size.height-95;
//    }
    
    minValue=100000000;
    maxValue=0;
    
    minAsk=100000000;
    maxBid=0;
    
    for(NSDictionary *n in self.changes)
    {
        if([n[@"Ask"] floatValue]>maxValue)
            maxValue=[n[@"Ask"] floatValue];
        if([n[@"Bid"] floatValue]>maxValue)
            maxValue=[n[@"Bid"] floatValue];
        
        if([n[@"Bid"] floatValue]<minValue && [n[@"Bid"] doubleValue]>0)
            minValue=[n[@"Bid"] floatValue];
        
        if([n[@"Ask"] floatValue]<minAsk && [n[@"Ask"] floatValue] > 0)
            minAsk=[n[@"Ask"] floatValue];
        if([n[@"Bid"] floatValue]>maxBid)
            maxBid=[n[@"Bid"] floatValue];

    }
    
    if(maxBid==0)
        maxBid=minAsk;
    if(minValue>minAsk)
        minValue=minAsk;
    
    if(maxValue==minValue)
        maxValue=maxValue+maxValue/1000;
    
    [self setNeedsLayout];

}

-(void) layoutSubviews
{
    if(!_changes)
        return;
    CGSize size=self.frame.size;
//    minGraphY=100;
//    maxGraphY=self.bounds.size.height-140;
    
//    if([UIScreen mainScreen].bounds.size.width==320)
//    {
//        minGraphY=55;
//        maxGraphY=self.bounds.size.height-95;
//    }

    maxGraphY=self.bounds.size.height-120;
    if([UIScreen mainScreen].bounds.size.width == 320) {
        maxGraphY = self.bounds.size.height - 80;
        minGraphY = 65;
    }


    yellowDot.hidden=NO;
    purpleDot.hidden=NO;
    
   CGFloat yAsk=[self point:[_changes.lastObject[@"Ask"] floatValue] forSize:size];
    CGFloat yBid=[self point:[_changes.lastObject[@"Bid"] floatValue] forSize:size];
    
    yellowDot.center=CGPointMake(self.bounds.size.width, yAsk);
    purpleDot.center=CGPointMake(self.bounds.size.width, yBid);
    
}

-(void) drawRect:(CGRect)rect
{

    CGContextRef context=UIGraphicsGetCurrentContext();
    
    int width=(int)CGBitmapContextGetWidth(context);
    int height=(int)CGBitmapContextGetHeight(context);
    
    unsigned char *bitmap=CGBitmapContextGetData(context);
    
    int step=(int)CGBitmapContextGetBytesPerRow(context);
//    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
     CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.0);

    CGContextFillRect(context, (CGRect){CGPointZero, CGSizeMake(width, height)});
    
    NSDictionary *firstPoint = self.changes[0];
    NSDictionary *lastPoint = self.changes[self.changes.count - 1];

    
    CGContextSetRGBStrokeColor(context, 19.0/255, 183.0/255, 42.0/255, 1.0);
    CGContextSetRGBFillColor(context, 19.0/255, 183.0/255, 42.0/255, 1.0);
    
    if([firstPoint[@"Ask"] floatValue]>[lastPoint[@"Ask"] floatValue])
    {
        CGContextSetRGBStrokeColor(context, 255.0/255, 62.0/255, 46.0/255, 1.0);
        CGContextSetRGBFillColor(context, 255.0/255, 62.0/255,46.0/255, 1.0);
    }
    
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    CGContextSetLineWidth(context, 1);
    
    CGContextSetAllowsAntialiasing(context, false);
//    CGContextSetMiterLimit(context, 0);
    
    CGMutablePathRef pathRef;
    
    CGSize const size=self.frame.size;
    
    minTopGraphPoint=[self point:minAsk forSize:size];
    maxBottomGraphPoint=[self point:maxBid forSize:size];

    if(self.changes && self.changes.count >= 2)
    {
        CGFloat xMargin=0.0;
        CGFloat const xStep=roundf((size.width-xMargin)/(self.changes.count-1));
//        CGFloat const xStep = 5;
        CGFloat xPosition=-xStep;
        coeff=(maxValue-minValue)/(maxGraphY-minGraphY);

        CGFloat yPosition;
        
        
        
        
        
        ////// try gradient
        
        
        
        xPosition=-xStep;
        
        
        coeff=(maxValue-minValue)/(maxGraphY-minGraphY);
        
        
        CGContextSetRGBStrokeColor(context, 255.0/255, 174.0/255, 44.0/255, 1.0);
        CGContextSetRGBFillColor(context, 255.0/255, 174.0/255, 44.0/255, 1.0);
        
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        CGFloat colors1[] =
        {
//            1.0, 1.0, 1.0, 1.0,   //RGBA values (so red to green in this case)
//            1.0, 247.0/255.0, 234.0/255.0, 1.0
            1.0, 1.0, 1.0, 0.0,
            1.0, 1.0, 1.0, 0.0
        };
        
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors1, NULL, 2);
        
        
//        CGContextRef currentContext = UIGraphicsGetCurrentContext();
//        CGContextSetBlendMode(currentContext, kCGBlendModeDestinationOver);
        
//        CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
//        size_t num_locations = 2;
//        CGFloat locations[2] = {0.f, 1.f};
//        CGFloat components[8] = {1.f, 1.f, 1.f, .5f, // top color
//            1.f, 1.f, 1.f, .2f}; // bottom color
//        CGGradientRef gradient2 = CGGradientCreateWithColorComponents(rgbColorSpace, components, locations, num_locations);
//        CGRect currentBounds = self.bounds;
//        CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.f);
//        CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));
//        CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, midCenter, 0);
        
//        CGGradientRelease(glossGradient);
//        CGColorSpaceRelease(rgbColorSpace);

        CGFloat colors2[] =
        {
//            1.0, 1.0, 1.0, 1.0,   //RGBA values (so red to green in this case)
//            246.0/255.0, 229.0/255.0, 1.0, 1.0
            
            
//             60.0/255.0, 172.0/255.0, 227.0/255.0, 0.0,
//            102.0/255.0, 164.0/255.0, 216.0/255.0, 1.0,
            1.0, 1.0, 1.0, 0.0,
            1.0, 1.0, 1.0, 0.4
        };
        
        CGGradientRef gradient2 = CGGradientCreateWithColorComponents(colorSpace, colors2, NULL, 2);

        
        //Where the 2 is for the number of color components. You can have more colors throughout //your gradient by adding to the colors[] array, and changing the components value.
        
        CGColorSpaceRelease(colorSpace);

        
        yPosition=[self point:[firstPoint[@"Ask"] floatValue] forSize:size];
        
        for(NSDictionary *change in self.changes)
        {
            if([change[@"Ask"] floatValue] > 0) {
                
                yPosition=[self point:[change[@"Ask"] floatValue] forSize:size];
                
                pathRef = CGPathCreateMutable();
                
                CGPathAddRect(pathRef, NULL, CGRectMake(xPosition, 0, xStep, yPosition));
                
                CGContextSaveGState(context);
                
                CGContextAddPath(context, pathRef);
                CGContextClip(context);
                
                CGContextDrawLinearGradient(context, gradient, CGPointMake(xPosition, 0), CGPointMake(xPosition, [self point:minAsk forSize:size]), 0);
                
                CGContextDrawPath(context, kCGPathFillStroke);
//                CGContextDrawPath(context, kCGPathEOFillStroke);
                
                //            CGGradientRelease(gradient);
                CGContextRestoreGState(context);
                CGPathRelease(pathRef);
                
            }
            
            if([change[@"Bid"] floatValue] > 0) {
                yPosition=[self point:[change[@"Bid"] floatValue] forSize:size];
                
                pathRef = CGPathCreateMutable();
                
                CGPathAddRect(pathRef, NULL, CGRectMake(xPosition, yPosition, xStep, self.bounds.size.height - yPosition));
                
                CGContextSaveGState(context);
                
                CGContextAddPath(context, pathRef);
                CGContextClip(context);
                
//                CGContextDrawLinearGradient(context, gradient2, CGPointMake(xPosition, self.bounds.size.height), CGPointMake(xPosition, [self point:maxBid forSize:size]), 0);
                
                 CGContextDrawLinearGradient(context, gradient2, CGPointMake(xPosition, self.bounds.size.height), CGPointMake(xPosition, [self point:maxBid forSize:size]), 0);
                
                CGContextDrawPath(context, kCGPathFillStroke);
                
                //            CGGradientRelease(gradient);
                CGContextRestoreGState(context);
                CGPathRelease(pathRef);
                
                
                
            }
            
            
            
            
            
            
            
            
            
            
            

            
//            CGPathAddLineToPoint(pathRef, NULL, xPosition, yPosition);
            
            xPosition += xStep;
            
//            CGPathAddLineToPoint(pathRef, NULL, xPosition, yPosition);
            
            

        }
        
        
        
//        CGContextAddPath(context, pathRef);
//        CGContextStrokePath(context);
        
//        CGPathRelease(pathRef);

        
        
        
        
        
        //////
        
        
        pathRef = CGPathCreateMutable();
        xMargin=0.0;
        xPosition=-xStep;
        
        
        
        
    //    CGContextSetRGBStrokeColor(context, 255.0/255, 174.0/255, 44.0/255, 1.0);
    //    CGContextSetRGBFillColor(context, 255.0/255, 174.0/255, 44.0/255, 1.0);
        
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.4);
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.4);
        
        
        yPosition=[self point:[firstPoint[@"Ask"] floatValue] forSize:size];
        CGPathMoveToPoint(pathRef, NULL, xPosition, yPosition);
        BOOL flagZero = NO;
        for(NSDictionary *change in self.changes)
        {
            if([change[@"Ask"] floatValue] != 0) {
                yPosition=[self point:[change[@"Ask"] floatValue] forSize:size];

                if(flagZero) {
                    CGPathMoveToPoint(pathRef, NULL, xPosition, yPosition);
                    flagZero = NO;
                }
                else {
                    CGPathAddLineToPoint(pathRef, NULL, xPosition, yPosition);
                }
            }
            else {
                flagZero = true;
            }
            
            xPosition += xStep;
            if([change[@"Ask"] floatValue] != 0) {
                CGPathAddLineToPoint(pathRef, NULL, xPosition, yPosition);
            }
            
        }
        
        
        
        CGContextAddPath(context, pathRef);
        CGContextStrokePath(context);
        
        CGPathRelease(pathRef);

        
        
        
        
        
        
        
        
        
        
        

        
        pathRef = CGPathCreateMutable();


    //    CGContextSetRGBStrokeColor(context, 171.0/255, 0.0/255, 255.0/255, 1.0);
    //    CGContextSetRGBFillColor(context, 171.0/255, 0.0/255,255.0/255, 1.0);
        
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.8);
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.8);
        
        xPosition=-xStep;
//        yPosition=-1;
        
        flagZero = NO;
        
        yPosition=[self point:[firstPoint[@"Bid"] floatValue] forSize:size];
        CGPathMoveToPoint(pathRef, NULL, xPosition, yPosition);

        
        for(NSDictionary *change in self.changes)
        {
            
//            if(yPosition==-1 && [change[@"Bid"] floatValue]>0)
//            {
//                yPosition=[self point:[change[@"Bid"] floatValue] forSize:size];
//                CGPathMoveToPoint(pathRef, NULL, xPosition, yPosition);
//
//            }
//            else if(yPosition==-1)
//            {
//                xPosition += xStep;
//
//                continue;
//            }
//            yPosition=[self point:[change[@"Bid"] floatValue] forSize:size];
//            
//            NSLog(@"%f %f", yPosition, [change[@"Bid"] floatValue]);
//
//            CGPathAddLineToPoint(pathRef, NULL, xPosition, yPosition);
//            
//            xPosition += xStep;
//
//            CGPathAddLineToPoint(pathRef, NULL, xPosition, yPosition);
            
            if([change[@"Bid"] floatValue] != 0) {
                yPosition=[self point:[change[@"Bid"] floatValue] forSize:size];
                
                if(flagZero) {
                    CGPathMoveToPoint(pathRef, NULL, xPosition, yPosition);
                    flagZero = NO;
                }
                else {
                    CGPathAddLineToPoint(pathRef, NULL, xPosition, yPosition);
                }
            }
            else {
                flagZero = true;
            }
            
            xPosition += xStep;
            if([change[@"Bid"] floatValue] != 0) {
                CGPathAddLineToPoint(pathRef, NULL, xPosition, yPosition);
            }

        }

        CGContextAddPath(context, pathRef);
        CGContextStrokePath(context);

        
        
        CGPathRelease(pathRef);
    }
    
    
    
    
    return; //Testing
    
    if(!_changes)
        return;
    
    float r1=231;
    float g1=247;
    float b1=233;
    
    if([firstPoint[@"Ask"] floatValue]>[lastPoint[@"Ask"] floatValue])
    {
        r1=255;
        g1=235;
        b1=244;
    }
    
    for(int x=0;x<width-2;x++)  //width-2 removes thin line at the right
    {
        int mode=0;

        unsigned char *offset=bitmap+x*4;
        offset-=step;
        
        for(int y=0;y<height;y++)
        {
            offset+=step;
            
            if(*(offset+1)==(unsigned char)174)
            {
                mode=1;
                continue;
            }
            if(*(offset+1)==(unsigned char)0x0)
            {
                mode=2;
                continue;
            }
            
            if(mode==0)
            {
                float p=(float)(height-y)/height;
                
                p=(float)(minTopGraphPoint-y)/minTopGraphPoint;
                
                r1=255;
                g1=247;
                b1=234;

                
                char r=(char)(255*p+(1-p)*255);
                char g=(char)(255*p+(1-p)*247);
                char b=(char)(255*p+(1-p)*234);
                
                
                
                *(offset)=b;
                *(offset+1)=g;
                *(offset+2)=r;
                continue;
            }
            if(mode==2)
            {
                float p=(float)(height-y)/height;
                
                p=1.0-(float)(y-maxBottomGraphPoint)/(height-maxBottomGraphPoint);
                
                
                
                r1=246;
                g1=229;
                b1=255;
                
                
                char r=(char)(r1*p+(1-p)*255);
                char g=(char)(g1*p+(1-p)*255);
                char b=(char)(b1*p+(1-p)*255);
                
                
                
                *(offset)=b;
                *(offset+1)=g;
                *(offset+2)=r;
                continue;
            }

            
        }
    }
    
//    NSLog(@"Boza kralj");
    self.opaque = NO;
}

- (CGFloat)point:(float) point forSize:(CGSize)size {
    
    float result=minGraphY+((point-minValue)/(maxValue-minValue))*(maxGraphY-minGraphY);
    result=size.height-result;
    return result;
}





@end
