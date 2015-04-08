//
//  CoolLabel.m
//  DVQuiz
//
//  Created by Douglas Voss on 4/7/15.
//

#import "CoolLabel.h"
#import "math.h"

@implementation CoolLabel

- (id)initWithRoundedRectArcRadius:(CGFloat)radius
{
    self = [super init];
    _roundedRectArcRadius = radius;
    return self;
}

- (id)init
{
    return [self initWithRoundedRectArcRadius:30.0];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    CGColorSpaceRef myColorspace;
    
    CGGradientRef myTopGradient;
    size_t topNum_locations = 2;
    CGFloat topLocations[2] = { 0.0, 1.0 };
    CGFloat topComponents[4*2] = {
        0.9, 0.9, 1.0, 1.0,  // Start color
        0.4, 0.4, 0.7, 1.0  // End color
    };
    
    myColorspace = CGColorSpaceCreateDeviceRGB();

    CGPoint myStartPoint, myEndPoint;
    myStartPoint.x = rect.origin.x;
    myStartPoint.y = rect.origin.y;
    myEndPoint.x = myStartPoint.x;
    myEndPoint.y = rect.origin.y+(rect.size.height/2.0);
    myTopGradient = CGGradientCreateWithColorComponents (myColorspace, topComponents,
                                                         topLocations, topNum_locations);
    
    CGContextSaveGState(myContext);
    CGMutablePathRef roundedRectClipPath = CGPathCreateMutable();
    CGPathMoveToPoint(roundedRectClipPath, NULL, CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPathAddArcToPoint(roundedRectClipPath, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMaxY(rect), self.roundedRectArcRadius);
    CGPathAddArcToPoint(roundedRectClipPath, NULL, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMaxY(rect), self.roundedRectArcRadius);
    CGPathAddArcToPoint(roundedRectClipPath, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMinY(rect), self.roundedRectArcRadius);
    CGPathAddArcToPoint(roundedRectClipPath, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMinY(rect), self.roundedRectArcRadius);
//    CGPathAddArc(path, NULL, CGRectGetMidX(rect), CGRectGetMidY(rect), (rect.size.width/2.0), 0, M_PI, 1);
    CGPathCloseSubpath(roundedRectClipPath);
/*    CGContextBeginPath(myContext);
    CGContextAddArc (myContext, rect.origin.x+(rect.size.width/2.0), rect.origin.y+(rect.size.height/2.0), (rect.size.height/2.0), 0,
                     M_PI, 1);
    CGContextClosePath (myContext);*/
    
    CGContextAddPath(myContext, roundedRectClipPath);
    CGContextClip (myContext);
    CGContextDrawLinearGradient (myContext, myTopGradient, myStartPoint, myEndPoint, 0);
    CGGradientRelease (myTopGradient);
    CGContextRestoreGState(myContext);
    
    CGGradientRef myBottomGradient;
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
    CGContextAddPath(myContext, roundedRectClipPath);
    CGContextClip (myContext);
    CGContextDrawLinearGradient (myContext, myBottomGradient, myStartPoint, myEndPoint, 0);
    CGContextRestoreGState(myContext);

    CGColorSpaceRelease (myColorspace);
    
    [super drawRect:rect];
}


@end
