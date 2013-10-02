//
//  FSPanesSplitView.h
//  FSPanes
//
//  Created by Emil Wojtaszek on 11-03-27.
//  Copyright 2011 CreativeLabs.pl
//
//  Modified by Błażej Biesiada, Karol S. Mazur
//  Copyright 2012 Future Simple Inc.
//
//  Licensed under the Apache License, Version 2.0.
//

#import <UIKit/UIKit.h>

@class FSPanesSplitViewController;

@interface FSPanesSplitView : UIView
{
    UIView *_dividerView;
    CGFloat _dividerWidth;
}

@property (weak, nonatomic) FSPanesSplitViewController *splitViewController;

@property (nonatomic, strong, readonly) UIView *contentView;

@property (assign, nonatomic) CGFloat menuViewWidth;

@property (strong, nonatomic) UIImage *verticalDividerImage;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *menuView;
@property (strong, nonatomic) UIView *navigationView;

@end
