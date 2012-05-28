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

@interface FSPaneView : UIView

@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, strong) IBOutlet UIView *footerView;

@property CGFloat shadowWidth;

/** X-axis shadow offset. Default is 0.0f. */
@property CGFloat shadowOffset;

/** Set YES if you want rounded corners. Default is NO. */
@property BOOL showRoundedCorners;

/** Type of rect corners. Default UIRectCornerAllCorners. */
@property UIRectCorner rectCorner;

/** @return YES if loaded within container hierarchy, othwerise NO. */
@property (readonly) BOOL isLoaded;

@property FSViewSize viewSize;

- (id)initWithSize:(FSViewSize)size;

/** Adds left outer shadow view with proper width. */
- (void)addLeftBorderShadowView:(UIView *)view withWidth:(CGFloat)width;

@end
