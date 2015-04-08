//
//  CoolLabel.m
//  DVQuiz
//
//  Created by Douglas Voss on 4/7/15.
//

#import "CoolLabel.h"
#import "math.h"

@implementation CoolLabel

- (id)initWithColor:(UIColor *)color roundedRectArcRadius:(CGFloat)radius;
{
    self = [super init];
    _roundedRectArcRadius = radius;
    _color = color;
    return self;
}

- (id)initWithColor:(UIColor *)color
{
    return [self initWithColor:color roundedRectArcRadius:10.0];
}

- (id)initWithRoundedRectArcRadius:(CGFloat)radius
{
    return [self initWithColor:[UIColor blueColor] roundedRectArcRadius:radius];
}

- (id)init
{
    return [self initWithRoundedRectArcRadius:10.0];
}

- (CGMutablePathRef)makeRoundedRectPath:(CGRect)rect radius:(CGFloat)radius
{
    CGMutablePathRef clipPath = CGPathCreateMutable();
    CGPathMoveToPoint(clipPath, NULL, CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPathAddArcToPoint(clipPath, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMaxY(rect), radius);
    CGPathAddArcToPoint(clipPath, NULL, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMaxY(rect), radius);
    CGPathAddArcToPoint(clipPath, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMinY(rect), radius);
    CGPathAddArcToPoint(clipPath, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMinY(rect), radius);
    CGPathCloseSubpath(clipPath);
    
    return clipPath;
}

- (CGMutablePathRef)makeTopBubbleClipPath:(CGRect)rect
{
    CGFloat radius = rect.size.width*2.0;
    
    CGContextRef context;
    CGContextSaveGState(context);
    
    CGMutablePathRef clipPath = CGPathCreateMutable();
    //CGPathMoveToPoint(clipPath, NULL, CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPathAddArc(clipPath, NULL, CGRectGetMidX(rect), CGRectGetMidY(rect)-radius, radius, 2*M_PI, 0, true);
    CGPathCloseSubpath(clipPath);
    
    CGContextRestoreGState(context);
    
    return clipPath;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    
    CGFloat hue, saturation, brightness, alpha;
    [self.color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    //NSLog(@"hue=%f saturation=%f brightness=%f alpha=%f", hue, saturation, brightness, alpha);
    
    UIColor *topColor1 = [UIColor colorWithHue:hue saturation:(0.3*saturation) brightness:(1.0*brightness) alpha:alpha];
    UIColor *topColor2 = [UIColor colorWithHue:hue saturation:(0.8*saturation) brightness:(1.0*brightness) alpha:alpha];
    UIColor *bottomColor1 = [UIColor colorWithHue:hue saturation:(1.0*saturation) brightness:(1.0*brightness) alpha:alpha];
    UIColor *bottomColor2 = [UIColor colorWithHue:hue saturation:(1.0*saturation) brightness:(1.0*brightness) alpha:alpha];
    
    CGFloat topColor1Red, topColor1Green, topColor1Blue, topColor1Alpha;
    [topColor1 getRed:&topColor1Red green:&topColor1Green blue:&topColor1Blue alpha:&topColor1Alpha];
    
    CGFloat topColor2Red, topColor2Green, topColor2Blue, topColor2Alpha;
    [topColor2 getRed:&topColor2Red green:&topColor2Green blue:&topColor2Blue alpha:&topColor2Alpha];
    
    CGFloat bottomColor1Red, bottomColor1Green, bottomColor1Blue, bottomColor1Alpha;
    [bottomColor1 getRed:&bottomColor1Red green:&bottomColor1Green blue:&bottomColor1Blue alpha:&bottomColor1Alpha];
    
    CGFloat bottomColor2Red, bottomColor2Green, bottomColor2Blue, bottomColor2Alpha;
    [bottomColor2 getRed:&bottomColor2Red green:&bottomColor2Green blue:&bottomColor2Blue alpha:&bottomColor2Alpha];

    
    CGGradientRef topGradient;
    CGFloat topLocations[2] = { 0.0, 1.0 };
    CGFloat topComponents[4*2] = {
        topColor1Red, topColor1Green, topColor1Blue, topColor1Alpha,  // Start color
        topColor2Red, topColor2Green, topColor2Blue, topColor2Alpha   // End color
    };
    
    CGPoint startPoint, endPoint;
    startPoint.x = rect.origin.x;
    startPoint.y = rect.origin.y;
    endPoint.x = startPoint.x;
    endPoint.y = rect.origin.y+(rect.size.height/2.0);
    topGradient = CGGradientCreateWithColorComponents (colorspace, topComponents,
                                                    topLocations, 2);
    
    CGContextSaveGState(context);
    
    CGMutablePathRef roundedRectPath = [self makeRoundedRectPath:rect radius:self.roundedRectArcRadius];
    CGContextAddPath(context, roundedRectPath);
    CGContextClip (context);
    CGContextDrawLinearGradient (context, topGradient, startPoint, endPoint, 0);
    CGGradientRelease (topGradient);
    CGContextRestoreGState(context);
    
    
    CGGradientRef bottomGradient;
    CGFloat bottomLocations[2] = { 0.0, 1.0 };
    CGFloat bottomComponents[4*2] = {
        bottomColor1Red, bottomColor1Green, bottomColor1Blue, bottomColor1Alpha,  // Start color
        bottomColor2Red, bottomColor2Green, bottomColor2Blue, bottomColor2Alpha   // End color
    };
    
    startPoint.x = rect.origin.x;
    startPoint.y = rect.origin.y+(rect.size.height/2.0);
    endPoint.x = startPoint.x;
    endPoint.y = rect.origin.y+(rect.size.height);
    bottomGradient = CGGradientCreateWithColorComponents (colorspace, bottomComponents,
                                                    bottomLocations, 2);
    
    CGContextSaveGState(context);
    CGContextAddPath(context, roundedRectPath);
    CGContextClip (context);
    CGContextDrawLinearGradient (context, bottomGradient, startPoint, endPoint, 0);
    CGGradientRelease (bottomGradient);
    CGContextRestoreGState(context);
    
    
/*
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    CGMutablePathRef roundedRectPath = [self makeRoundedRectPath:rect radius:self.roundedRectArcRadius];
    CGContextAddPath(context, roundedRectPath);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
*/
    
/*    CGGradientRef myBottomGradient;
    size_t bottomNum_locations = 2;
    CGFloat bottomLocations[2] = { 0.0, 1.0 };
    CGFloat bottomComponents[4*2] = {
        0.2, 0.1, 0.0, 1.0,  // Start color
        0.87, 0.72, 0.52, 1.0  // End color
    };
    
    myStartPoint = myEndPoint;
    myEndPoint.x = rect.origin.x;
    myEndPoint.y = rect.origin.y+(rect.size.height);
    myBottomGradient = CGGradientCreateWithColorComponents (myColorspace, bottomComponents,
                                                            bottomLocations, bottomNum_locations);
    CGContextSaveGState(myContext);
    CGContextAddPath(myContext, roundedRectPath);
    CGContextClip (myContext);
    CGContextDrawLinearGradient (myContext, myBottomGradient, myStartPoint, myEndPoint, 0);
    CGGradientRelease (myBottomGradient);
    CGContextRestoreGState(myContext);*/
    
    
/*    CGRect alphaHighlightRect;
    alphaHighlightRect.origin.x = rect.origin.x+(rect.size.width/64.0);
    alphaHighlightRect.origin.y = rect.origin.y+((rect.size.height/2.0)/16.0);
    alphaHighlightRect.size.width = rect.size.width*(16.0/64.0);
    alphaHighlightRect.size.height = (rect.size.height/2.0)*(14.0/16.0);*/
    
/*    CGMutablePathRef alphaHighlightClipPath = [self makeTopBubbleClipPath:rect];
    CGGradientRef alphaHighlightGradient;
    CGFloat alphaHighlightLocations[2] = { 0.0, 1.0 };
    CGFloat alphaHighlightComponents[4*2] = {
        1.0, 1.0, 1.0, 0.0,  // Start color
        1.0, 1.0, 1.0, 1.0  // End color
    };
    
    myStartPoint.x = rect.origin.x;
    myStartPoint.y = rect.origin.y;
    myEndPoint.x = myStartPoint.x;
    myEndPoint.y = myStartPoint.y+(rect.size.height);
    alphaHighlightGradient = CGGradientCreateWithColorComponents (myColorspace, alphaHighlightComponents,                                                            alphaHighlightLocations, 2);
    CGContextSaveGState(myContext);
    CGContextAddPath(myContext, alphaHighlightClipPath);
    CGContextClip (myContext);
    CGContextDrawLinearGradient (myContext, alphaHighlightGradient, myStartPoint, myEndPoint, 0);
    CGGradientRelease (alphaHighlightGradient);
    CGContextRestoreGState(myContext);
*/

    CGColorSpaceRelease (colorspace);
    
    [super drawRect:rect];
}


@end
