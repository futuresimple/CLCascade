//
//  FSPaneBorderShadowView.m
//  FSPanes
//
//  Created by Emil Wojtaszek on 23.08.2011.
//  Copyright (c) 2011 AppUnite
//
//  Modified by Błażej Biesiada, Karol S. Mazur
//  Copyright 2012 Future Simple Inc.
//
//  Licensed under the Apache License, Version 2.0.
//

#import "FSPaneBorderShadowView.h"

@interface FSPaneBorderShadowView ()
{
    BOOL _rightSide;
}

@end

@implementation FSPaneBorderShadowView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (id)init 
{
    return [self initWithFrame:CGRectZero];
}

- (id)initForLeftSide {
    if (self = [self init]) {
        _rightSide = NO;
    }
    return self;
}

- (id)initForRightSide {
    if (self = [self init]) {
        _rightSide = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect 
{
    CGFloat colors [] = { 
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.3
    };
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint startPoint = CGPointMake(0, CGRectGetMidY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
    
    if (_rightSide) {
        CGPoint temp = startPoint;
        startPoint = endPoint;
        endPoint = temp;
    }

    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
}

@end
