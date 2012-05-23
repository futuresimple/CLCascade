//
//  UIViewController+FSPanes.h
//  FSPanes
//
//  Created by Błażej Biesiada on 5/11/12.
//  Copyright 2012 Future Simple Inc.
//
//  Licensed under the Apache License, Version 2.0.
//

#import <UIKit/UIKit.h>

@class FSPanesNavigationController;
@class FSPanesSplitViewController;

@interface UIViewController (FSPanes)

@property(nonatomic, readonly, retain) FSPanesSplitViewController *panesSplitViewController;
@property(nonatomic, readonly, retain) FSPanesNavigationController *panesNavigationController;

@end
