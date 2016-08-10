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
#import <UIKit/UIKit.h>

#import "FSPanesGlobal.h"

@class FSPanesMenuViewController, FSPanesMenuItem;
@class FSPanesNavigationController, FSPanesNavigationItem;

@protocol FSPaneControllerDelegate <NSObject>

@optional

/** 
 Implement this getter if you want a pane navigation bar. 
 Return the view you want to see in the navigation bar.
*/
@property (readonly, nonatomic) UIView *paneNavigationBarView;

/** 
 All panes are by default FSPaneSizeRegular. 
 Implement this getter and return FSPaneSizeWide if you want otherwise.
*/
@property (readonly, nonatomic) FSPaneSize paneSize;

@end
