//
//  FSPanesProtocols.h
//  FSPanes
//
//  Created by Karol S. Mazur on 5/31/12.
//  Copyright (c) 2012 Applicake. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0.
//

#import <Foundation/Foundation.h>

@class FSPanesMenuViewController;

/** Root VCs (pushed on PanesSplitVC) should conform to this protocol. */
@protocol FSPanesMenuItems <NSObject>

@optional
- (NSString *)iconNameForPanesMenu:(FSPanesMenuViewController *)panesMenuViewController;
- (NSString *)selectedIconNameForPanesMenu:(FSPanesMenuViewController *)panesMenuViewController;

@end

@class FSPanesNavigationItem, FSPanesNavigationController;

/** Conform to this protocol if you want a navigation bar for your pane. */
@protocol FSPanesNavigationItem <NSObject>

@optional
- (FSPanesNavigationItem *)navigationItemForPanesNavigation:(FSPanesNavigationController *)panesNavigationController;

@end
