//
//  UIViewController+FSPaneView.m
//  FSPanes
//
//  Created by Emil Wojtaszek on 11-05-07.
//  Copyright 2011 AppUnite
//
//  Modified by Błażej Biesiada, Karol S. Mazur
//  Copyright 2012 Future Simple Inc.
//
//  Licensed under the Apache License, Version 2.0.
//

#import "UIViewController+FSPaneView.h"


@implementation UIViewController (UIViewController_FSPaneView)

@dynamic segmentedView;
@dynamic headerView;
@dynamic contentView;

- (FSPaneView *)segmentedView
{
    UIView *contentView = [self.view superview];
    return (FSPaneView *)[contentView superview];
}


- (UIView *)headerView
{
    if (![self.segmentedView isKindOfClass:[FSPaneView class]]) {
        return nil;
    }
    
    FSPaneView *view_ = (FSPaneView *)self.segmentedView;
    return view_.headerView;
}

- (UIView *)contentView
{
    if (![self.segmentedView isKindOfClass:[FSPaneView class]]) {
        return self.view;
    }
    
    FSPaneView *view_ = (FSPaneView *)self.segmentedView;
    return view_.contentView;
}

@end
