//
//  FSPanesSplitViewController.h
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

@class FSPanesMenuViewController;
@class FSPanesNavigationController;

@interface FSPanesSplitViewController : UIViewController

@property (nonatomic, strong) FSPanesMenuViewController *panesMenuViewController;
@property (nonatomic, strong) FSPanesNavigationController *panesNavigationController; //it should be readonly

- (id)initWithNavigationController:(FSPanesNavigationController *)navigationController;

- (void)setBackgroundView:(UIView *)backgroundView;
- (void)setDividerImage:(UIImage *)image;

@end
