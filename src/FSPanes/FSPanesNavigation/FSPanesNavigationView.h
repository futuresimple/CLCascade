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
#import "FSPaneView.h"

@class FSPanesNavigationView;

@protocol FSPanesNavigationViewDataSource <NSObject>

@required
- (UIView *)navigationView:(FSPanesNavigationView *)navigationView viewAtIndex:(NSInteger)index;
- (NSInteger)numberOfPanesInCascadeView:(FSPanesNavigationView *)navigationView;

@end

@protocol FSPanesNavigationViewDelegate <NSObject>

@optional
- (void)cascadeView:(FSPanesNavigationView *)navigationView didLoadPane:(UIView *)pane;
- (void)cascadeView:(FSPanesNavigationView *)navigationView didUnloadPane:(UIView *)pane;

- (void)cascadeView:(FSPanesNavigationView *)navigationView didAddPane:(UIView *)pane animated:(BOOL)animated;
- (void)cascadeView:(FSPanesNavigationView *)navigationView didPopPaneAtIndex:(NSInteger)index;

/** Called when pane will be unveiled by another pane or will slide in PanesNavigationView bounds */
- (void)cascadeView:(FSPanesNavigationView *)navigationView paneDidAppearAtIndex:(NSInteger)index;

/** Called when pane will be shadowed by another pane or will slide out PanesNavigationView bounds */
- (void)cascadeView:(FSPanesNavigationView *)navigationView paneDidDisappearAtIndex:(NSInteger)index;

- (void)navigationViewDidStartPullingToDetachPanes:(FSPanesNavigationView *)navigationView;
- (void)navigationViewDidPullToDetachPanes:(FSPanesNavigationView *)navigationView;
- (void)navigationViewDidCancelPullToDetachPanes:(FSPanesNavigationView *)navigationView;

@end

@interface FSPanesNavigationView : UIView <
UIScrollViewDelegate>

@property (nonatomic, weak) NSObject <FSPanesNavigationViewDelegate> *delegate;
@property (nonatomic, weak) NSObject <FSPanesNavigationViewDataSource> *dataSource;

/** 
 Left inset of normal pane from left screen edge. Default 70.0f
 If you change this property, width of single pane will change.
*/
@property(nonatomic) CGFloat leftInset;

/** Left inset of wider pane from left boarder. Default 220.0f */
@property(nonatomic) CGFloat widerLeftInset;

- (void)pushView:(UIView *)newView animated:(BOOL)animated;
- (void)pushView:(UIView *)newView animated:(BOOL)animated viewSize:(FSViewSize)viewSize;

- (void)replaceViewAtIndex:(NSUInteger)oldViewIndex 
                  withView:(UIView *)newView 
                  viewSize:(FSViewSize)viewSize;

- (void)popPaneAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)popAllPanesAnimated:(BOOL)animated;

- (void)unloadInvisiblePanes;

- (NSInteger)indexOfFirstVisibleView:(BOOL)loadIfNeeded;
- (NSInteger)indexOfLastVisibleView:(BOOL)loadIfNeeded;
- (NSArray *)visiblePanes;

- (void)updateContentLayoutToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
                                         duration:(NSTimeInterval)duration;

@end
