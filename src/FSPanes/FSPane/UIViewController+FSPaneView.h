//
//  UIViewController+FSPaneView.h
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

#import <Foundation/Foundation.h>
#import "FSPaneView.h"

@interface UIViewController (UIViewController_FSPaneView)

@property (nonatomic, retain, readonly) UIView *headerView;
@property (nonatomic, retain, readonly) UIView *contentView;

@property (nonatomic, retain) FSPaneView *segmentedView;

@end
