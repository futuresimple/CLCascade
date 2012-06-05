//
//  FSPanesNavigationController.h
//  Panes
//
//  Created by Emil Wojtaszek on 11-05-06.
//  Copyright 2011 AppUnite
//
//  Modified by Błażej Biesiada, Karol S. Mazur
//  Copyright 2012 Future Simple Inc.
//
//  Licensed under the Apache License, Version 2.0.
//

#import <UIKit/UIKit.h>
#import "FSPanesGlobal.h"
#import "FSPanesNavigationView.h"
#import "FSPanesProtocols.h"

@interface FSPanesNavigationController : UIViewController <
FSPanesNavigationViewDataSource, 
FSPanesNavigationViewDelegate>

/**
 Left inset of normal size panes from left border. Default is 70.0f.
*/
@property (nonatomic) CGFloat leftInset;

/**
 Left inset of wider size pane from left border. Default is 220.0f.
*/
@property (nonatomic) CGFloat widerLeftInset;

/**
 viewController can conform to <FSPaneControllerDelegate> if you want to leverage FSPanes fully.
*/
- (void)setRootViewController:(UIViewController *)viewController
                     animated:(BOOL)animated;

/** 
 Push new view controller from sender.
 If sender is not last, then controller pop next controller and push new view from sender
 viewController can conform to <FSPaneControllerDelegate> if you want to leverage FSPanes fully.
*/
- (void)addViewController:(UIViewController *)viewController 
                   sender:(UIViewController *)sender 
                 animated:(BOOL)animated;

- (UIViewController *)rootViewController;
- (UIViewController *)lastViewController;
- (UIViewController *)firstVisibleViewController;

@end
