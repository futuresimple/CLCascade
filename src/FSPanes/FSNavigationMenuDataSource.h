//
//  FSNavigationMenuDataSource.h
//  Base-iOS-client
//
//  Created by Michał Śmiałko on 10.01.2013.
//  Copyright (c) 2013 Future Simple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FSNavigationMenuDataSource <NSObject>
@required
- (Class)viewControllerClassAtIndex:(NSInteger)index;
- (NSInteger)numberOfMenuItems;
- (NSInteger)indexOfViewController:(UIViewController *)viewController;
- (NSString *)titleOfViewControllerAtIndex:(NSInteger)index;
- (UIColor *)colorForViewControllerTitleAtIndex:(NSInteger)index; // can be nil - i.e. use default color
- (UIImage *)menuIconForViewControllerAtIndex:(NSInteger)index;
- (UIImage *)menuHighlightedIconForViewControllerAtIndex:(NSInteger)index;
- (UIViewController *)viewControllerForMenuItemAtIndex:(NSInteger)index;
@end
