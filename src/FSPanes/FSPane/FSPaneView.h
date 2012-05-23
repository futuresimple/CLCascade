//
//  FSPaneView.h
//  FSPanes
//
//  Created by Emil Wojtaszek on 11-04-24.
//  Copyright 2011 AppUnite
//
//  Modified by Błażej Biesiada, Karol S. Mazur
//  Copyright 2012 Future Simple Inc.
//
//  Licensed under the Apache License, Version 2.0.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FSPanesGlobal.h"

@interface FSPaneView : UIView {
    FSViewSize _viewSize;
    
    UIView* _headerView;
    UIView* _footerView;
    UIView* _contentView;
    UIView* _roundedCornersView;
    
    CGFloat _shadowWidth;
    CGFloat _shadowOffset;
    UIView* _shadowView;
    
    BOOL _showRoundedCorners;
    UIRectCorner _rectCorner;
}

/*
 * Header view - located on the top of view
 */
@property (nonatomic, strong) IBOutlet UIView* headerView;

/*
 * Footer view - located on the bottom of view
 */
@property (nonatomic, strong) IBOutlet UIView* footerView;

/*
 * Content view - located between header and footer view 
 */
@property (nonatomic, strong) IBOutlet UIView* contentView;

/*
 * The width of the shadow
 */
@property (nonatomic, assign) CGFloat shadowWidth;

/*
 * The offset of the shadow in X-axis. Default 0.0
 */
@property (nonatomic, assign) CGFloat shadowOffset;

/*
 * Set YES if you want rounded corners. Default NO.
 */
@property (nonatomic, assign) BOOL showRoundedCorners;

/*
 * Type of rect corners. Default UIRectCornerAllCorners.
 */
@property (nonatomic, assign) UIRectCorner rectCorner;

/*
 * Returns view's load status within container's hierarchy 
 */
@property (nonatomic, readonly) BOOL isLoaded;

/*
 * Size of view
 */
@property (nonatomic, assign, readonly) FSViewSize viewSize;

- (id) initWithSize:(FSViewSize)size;

/* 
 * This methoad add left outer shadow view with proper width
 */
- (void) addLeftBorderShadowView:(UIView *)view withWidth:(CGFloat)width;

@end
