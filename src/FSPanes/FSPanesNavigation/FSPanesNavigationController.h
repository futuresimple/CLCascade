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


@property (nonatomic, readonly) FSPanesNavigationView *navigationView;

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

- (void)popViewControler:(UIViewController *)viewController animated:(BOOL)animated;

- (UIViewController *)rootViewController;
- (UIViewController *)lastViewController;
- (UIViewController *)firstVisibleViewController;

@end
