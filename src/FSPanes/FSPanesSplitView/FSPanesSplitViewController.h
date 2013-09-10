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
@protocol FSNavigationMenuDataSource;

@interface FSPanesSplitViewController : UIViewController

+ (BOOL)isRunningIOS6;

/**
 View class used by controller. Defaults to `[FSPanesSplitView class]`.
 Subclasses may override this method to return their custom view classes.
 View class must descend from FSPanesSplitView.
 */
- (Class)viewClass;

@property (readonly, strong, nonatomic) FSPanesMenuViewController *panesMenuViewController;
@property (readonly, strong, nonatomic) FSPanesNavigationController *panesNavigationController;

/**
 Use this initializer if you want to use a subclass of FSPanesMenuViewController.
 If navigationController is nil, default FSPanesNavigationController is initialized.
 If menuViewController is nil, default FSPanesMenuViewController is initialized.
*/
- (id)initWithCustomNavigationController:(FSPanesNavigationController *)navigationController
                      menuViewController:(FSPanesMenuViewController *)menuViewController 
           rootPaneControllersDataSource:(id <FSNavigationMenuDataSource>) dataSource;


/**
 Left inset of normal size panes from left border. Default is 70.0f.
 */
@property (nonatomic, readwrite) CGFloat leftInset;

/**
 Convenience initializer. Will init default FSPanesMenuViewController and FSPanesNavigationController.
*/
- (id)initWithRootPaneControllersDataSource:(id <FSNavigationMenuDataSource>)dataSource;

- (void)setBackgroundView:(UIView *)backgroundView;
- (void)setDividerImage:(UIImage *)image;

/**
 The index of the view controller associated with the currently selected menu item.
 */
@property (nonatomic) NSUInteger selectedIndex;

@end
