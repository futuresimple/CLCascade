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
    NSMutableArray* _pages;
    
@private
    // sizes
    CGFloat _pageWidth;
    CGFloat _widePageWidth;
    CGFloat _leftInset;
    CGFloat _widerLeftInset;
    
    BOOL _pullToDetachPages;
    
    struct {
        unsigned int willDetachPages:1;
        unsigned int isDetachPages:1;
        unsigned int hasWiderPage:1;
    } _flags;
    
    NSInteger _indexOfFirstVisiblePage;
    NSInteger _indexOfLastVisiblePage;
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

/*
 * If YES, then pull to detach pages is enabled, default YES
 */
@property(nonatomic, assign) BOOL pullToDetachPages;


- (void) pushPage:(UIView*)newPage fromPage:(UIView*)fromPage animated:(BOOL)animated;
- (void) pushPage:(UIView*)newPage fromPage:(UIView*)fromPage animated:(BOOL)animated viewSize:(FSViewSize)viewSize;

- (void) popPageAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void) popAllPagesAnimated:(BOOL)animated;

- (UIView*) loadPageAtIndex:(NSInteger)index;

- (void) unloadInvisiblePages;

- (NSInteger) indexOfFirstVisibleView:(BOOL)loadIfNeeded;
- (NSInteger) indexOfLastVisibleView:(BOOL)loadIfNeeded;
- (NSArray*) visiblePages;

- (void) updateContentLayoutToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration;

- (BOOL) canPopPageAtIndex:(NSInteger)index; // @dodikk
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
