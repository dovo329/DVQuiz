//
//  CoolLabel.h
//  DVQuiz
//
//  Created by Douglas Voss on 4/7/15.
//

#import <UIKit/UIKit.h>

@interface CoolLabel : UILabel

@property (nonatomic, assign, readwrite) UIColor *color;
@property (nonatomic, assign, readwrite) CGFloat roundedRectArcRadius;

- (id)initWithColor:(UIColor *)color roundedRectArcRadius:(CGFloat)radius;
- (id)initWithColor:(UIColor *)color;
- (id)initWithRoundedRectArcRadius:(CGFloat)radius;
- (id)init;

@end
