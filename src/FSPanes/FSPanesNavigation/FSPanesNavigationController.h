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

@interface FSPanesNavigationController : UIViewController <FSPanesNavigationViewDataSource, FSPanesNavigationViewDelegate> {
    // view containing all views on stack
    FSPanesNavigationView *_navigationView;
}


/*
 * Left inset of normal size pages from left boarder
 */
@property(nonatomic) CGFloat leftInset;

/*
 * Left inset of wider size page from left boarder. Default 220.0f
 */
@property(nonatomic) CGFloat widerLeftInset;

/*
 * Set and push root view controller
 */
- (void) setRootViewController:(UIViewController*)viewController animated:(BOOL)animated;
- (void) setRootViewController:(UIViewController*)viewController animated:(BOOL)animated viewSize:(CLViewSize)viewSize;

/*
 * Push new view controller from sender.
 * If sender is not last, then controller pop next controller and push new view from sender
 */
- (void) addViewController:(UIViewController*)viewController sender:(UIViewController*)sender animated:(BOOL)animated;
- (void) addViewController:(UIViewController*)viewController sender:(UIViewController*)sender animated:(BOOL)animated viewSize:(FSViewSize)size;

- (UIViewController *) rootViewController;
- (UIViewController *) lastViewController;
- (UIViewController *) firstVisibleViewController;

@end
