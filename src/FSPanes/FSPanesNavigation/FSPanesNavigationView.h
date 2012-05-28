//
//  FSPanesNavigationView.h
//  FSPanes
//
//  Created by Emil Wojtaszek on 11-05-26.
//  Copyright 2011 AppUnite
//
//  Modified by Błażej Biesiada, Karol S. Mazur
//  Copyright 2012 Future Simple Inc.
//
//  Licensed under the Apache License, Version 2.0.
//

#import <UIKit/UIKit.h>
#import "FSPanesGlobal.h"
#import "FSPanesNavigationScrollView.h"

@protocol FSPanesNavigationViewDataSource;
@protocol FSPanesNavigationViewDelegate;

@interface FSPanesNavigationView : UIView <UIScrollViewDelegate> {
    // delegate and dataSource
    id<FSPanesNavigationViewDelegate> __unsafe_unretained _delegate;
    id<FSPanesNavigationViewDataSource> __unsafe_unretained _dataSource;
    
    // scroll view
    FSPanesNavigationScrollView *_scrollView;
    
    // contain all pages, if page is unloaded then page is respresented as [NSNull null]
    NSMutableArray *_panes;
    
@private
    // sizes
    CGFloat _paneWidth;
    CGFloat _widePaneWidth;
    CGFloat _leftInset;
    CGFloat _widerLeftInset;
    
    struct {
        unsigned int willDetachPanes:1;
        unsigned int isDetachPanes:1;
    } _flags;
    
    NSInteger _indexOfFirstVisiblePane;
    NSInteger _indexOfLastVisiblePane;
}

@property(nonatomic, unsafe_unretained) id<FSPanesNavigationViewDelegate> delegate;
@property(nonatomic, unsafe_unretained) id<FSPanesNavigationViewDataSource> dataSource;

/*
 * Left inset of normal pane from left screen edge. Default 70.0f
 * If you change this property, width of single pane will change.
 */
@property(nonatomic) CGFloat leftInset;

/*
 * Left inset of wider page from left boarder. Default 220.0f
 */
@property(nonatomic) CGFloat widerLeftInset;

- (void)pushView:(UIView*)newView fromView:(UIView*)fromView animated:(BOOL)animated;
- (void)pushView:(UIView*)newView fromView:(UIView*)fromView animated:(BOOL)animated viewSize:(FSViewSize)viewSize;

- (void)popPaneAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)popAllPanesAnimated:(BOOL)animated;

- (UIView *)loadPaneAtIndex:(NSInteger)index;

- (void)unloadInvisiblePanes;

- (NSInteger)indexOfFirstVisibleView:(BOOL)loadIfNeeded;
- (NSInteger)indexOfLastVisibleView:(BOOL)loadIfNeeded;
- (NSArray *)visiblePanes;

- (void)updateContentLayoutToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration;

@end

@protocol FSPanesNavigationViewDataSource <NSObject>
@required
- (UIView*) cascadeView:(FSPanesNavigationView*)cascadeView pageAtIndex:(NSInteger)index;
- (NSInteger) numberOfPagesInCascadeView:(FSPanesNavigationView*)cascadeView;
@end

@protocol FSPanesNavigationViewDelegate <NSObject>
@optional
- (void) cascadeView:(FSPanesNavigationView*)cascadeView didLoadPage:(UIView*)page;
- (void) cascadeView:(FSPanesNavigationView*)cascadeView didUnloadPage:(UIView*)page;

- (void) cascadeView:(FSPanesNavigationView*)cascadeView didAddPage:(UIView*)page animated:(BOOL)animated;
- (void) cascadeView:(FSPanesNavigationView*)cascadeView didPopPageAtIndex:(NSInteger)index;

/*
 * Called when page will be unveiled by another page or will slide in CascadeView bounds
 */
- (void) cascadeView:(FSPanesNavigationView*)cascadeView pageDidAppearAtIndex:(NSInteger)index;
/*
 * Called when page will be shadowed by another page or will slide out CascadeView bounds
 */
- (void) cascadeView:(FSPanesNavigationView*)cascadeView pageDidDisappearAtIndex:(NSInteger)index;

/*
 */
- (void) cascadeViewDidStartPullingToDetachPages:(FSPanesNavigationView*)cascadeView;
- (void) cascadeViewDidPullToDetachPages:(FSPanesNavigationView*)cascadeView;
- (void) cascadeViewDidCancelPullToDetachPages:(FSPanesNavigationView*)cascadeView;

@end
