//
//  CoolButton.h
//  CoolButton
//
//  Created by Douglas Voss on 4/6/15.
//  Copyright (c) 2015 Doug. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoolButton : UIButton

@property (nonatomic, assign, readwrite) CGFloat hue;
@property (nonatomic, assign, readwrite) CGFloat saturation;
@property (nonatomic, assign, readwrite) CGFloat brightness;

@end
