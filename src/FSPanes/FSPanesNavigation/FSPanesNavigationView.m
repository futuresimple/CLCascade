//
//  FSPanesNavigationView.m
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

#import "FSPanesNavigationView.h"
#import "FSPaneView.h"

#define DEFAULT_LEFT_INSET 70.0f
#define DEFAULT_WIDER_LEFT_INSET 220.0f
#define PULL_TO_DETACH_FACTOR 0.32f

//#define CONTESTED_CASE

@interface FSPanesNavigationView (DelegateMethods)
- (void) didLoadPage:(UIView*)page;
- (void) didAddPage:(UIView*)page animated:(BOOL)animated;
- (void) didPopPageAtIndex:(NSInteger)index;
- (void) didUnloadPage:(UIView*)page;
- (void) pageDidAppearAtIndex:(NSInteger)index;
- (void) pageDidDisappearAtIndex:(NSInteger)index;
- (void) didStartPullingToDetachPages;
- (void) didPullToDetachPages;
- (void) didCancelPullToDetachPages;
- (void) sendAppearanceDelegateMethodsIfNeeded;
- (void)sendDetachDelegateMethodsIfNeeded;
@end

@interface FSPanesNavigationView (Private)
- (NSArray *)_panesOnStock;

- (FSPaneView *)_paneAtIndex:(NSInteger)index;
- (BOOL)_paneExistsAtIndex:(NSInteger)index;
- (void)_unloadInvisiblePanesOnStock;

- (CGSize)_calculatePaneSize:(FSPaneView *)pane;
- (CGFloat)_calculateContentWidth;
- (UIEdgeInsets)_calculateEdgeInset:(UIInterfaceOrientation)interfaceOrientation;
- (CGPoint)_calculateOriginOfPaneAtIndex:(NSInteger)index;

- (void)_setProperContentSize;
- (void)_setProperEdgeInset:(BOOL)animated;
- (void)_setProperEdgeInset:(BOOL)animated forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)_setProperSizesForLoadedPanes:(UIInterfaceOrientation)interfaceOrientation;

- (FSPaneView *)_createPaneWithView:(UIView*)view size:(FSViewSize)viewSize;
- (FSPaneView *)_loadPaneAtIndex:(NSInteger)index;
- (void)_unloadPane:(FSPaneView*)pane remove:(BOOL)remove;
- (void)_loadBoundaryPanesIfNeeded;

- (NSInteger)_indexOfFirstVisiblePane;
- (NSInteger)_visiblePanesCount;

- (void)_setProperPositionOfPaneAtIndex:(NSInteger)index;
@end

@implementation FSPanesNavigationView

@synthesize leftInset = _leftInset; 
@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;
@synthesize widerLeftInset = _widerLeftInset;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _panes = [[NSMutableArray alloc] init];
        
        _flags.willDetachPanes = NO;
        _flags.isDetachPanes = NO;
        
        _indexOfFirstVisiblePane = -1;
        _indexOfLastVisiblePane = -1;
        
        _scrollView = [[FSPanesNavigationScrollView alloc] init]; // frame will be set in setter of _leftInset
        [_scrollView setDelegate:self];
        
        self.leftInset = DEFAULT_LEFT_INSET;
        self.widerLeftInset = DEFAULT_WIDER_LEFT_INSET;
        
        [self addSubview: _scrollView];
        
        [self setAutoresizingMask:
         UIViewAutoresizingFlexibleLeftMargin | 
         UIViewAutoresizingFlexibleRightMargin | 
         UIViewAutoresizingFlexibleBottomMargin | 
         UIViewAutoresizingFlexibleTopMargin | 
         UIViewAutoresizingFlexibleWidth | 
         UIViewAutoresizingFlexibleHeight];
    }
    
    return self;
}

- (void)dealloc
{
    _delegate = nil;
    _dataSource = nil;    
    _scrollView = nil;
    _panes = nil;
}

#pragma mark -
#pragma mark Custom accessors
- (void)setLeftInset:(CGFloat)newLeftInset
{
    CGFloat landscapeScreenWidth = [UIScreen mainScreen].bounds.size.height;
    CGFloat portraitScreenWidth = [UIScreen mainScreen].bounds.size.width;
    
    _leftInset = newLeftInset;
    _paneWidth = (landscapeScreenWidth - _leftInset) / 2.0f;
    _widePaneWidth = portraitScreenWidth - _leftInset;
    
    if (_widePaneWidth <= 0.0f) {
        NSAssert(NO, @"Left inset is too small!");
    }
    
    _scrollView.frame = CGRectMake(_leftInset, 0.0, _paneWidth, self.frame.size.height);
    
    [self _setProperEdgeInset:NO];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event 
{
    UIView *view = nil;
    
    NSEnumerator *enumerator = [[self visiblePanes] reverseObjectEnumerator];
    
    for (UIView *pane in enumerator) {
        CGRect rect = [_scrollView convertRect:pane.frame toView:self];
        
        if (CGRectContainsPoint(rect, point)) {
            CGPoint newPoint = [self convertPoint:point toView:pane];
            view = [pane hitTest:newPoint withEvent:event];
            break;
        }
    }
    
    if (view != nil) {
        return view;
    }
    else {
        return [super hitTest:point withEvent:event];
    }
}

- (void)pushView:(UIView*)newView fromView:(UIView*)fromView animated:(BOOL)animated
{
    [self pushView:newView fromView:fromView animated:animated viewSize:FSViewSizeNormal];
}

- (void)pushView:(UIView*)newView fromView:(UIView*)fromView animated:(BOOL)animated viewSize:(FSViewSize)viewSize
{
    FSPaneView *newPane = [self _createPaneWithView:newView size:viewSize];
    
    NSInteger paneIndex = [_panes count];
    
    CGSize paneSize = [self _calculatePaneSize:newPane];
    CGPoint paneOrigin = [self _calculateOriginOfPaneAtIndex:paneIndex];
    CGRect paneFrame = {.origin = paneOrigin, .size = paneSize};
    
    if (fromView == nil) {
        [self popAllPanesAnimated: animated];
        paneFrame.origin.x = 0.0f;
    }
    
    // animation of inserting a new root pane (from left to right)
    if (animated && fromView == nil && [_scrollView contentOffset].x >= 0) {
        CGRect initialAnimationFrame = CGRectMake(paneOrigin.x - paneSize.width, paneOrigin.y, paneSize.width, paneSize.height);
        newPane.frame = initialAnimationFrame;
        
        [UIView animateWithDuration:0.15 
                         animations: ^{
                             newPane.frame = paneFrame;
                         }];
    }
    else {
        newPane.frame = paneFrame;
    }
    
    CGFloat contentWidthBeforePush = [self _calculateContentWidth];
    
    [_panes addObject:newPane];
    
    [self _setProperContentSize];
    [self _setProperEdgeInset:NO];
    
    [_scrollView addSubview:newPane];
    
    // inform delegate
    [self didAddPage:newPane animated:animated];
    
    // scroll to new pane frame
    CGFloat horizontalOffset = contentWidthBeforePush;
    if (horizontalOffset < 0) { // when there is 'too much space'
        if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
            horizontalOffset = 0.0;
        }
        else {
            horizontalOffset = - (CATEGORIES_VIEW_WIDTH - _leftInset);
        }
    }
    else {
        CGFloat rightSideSpace = self.bounds.size.width - _scrollView.frame.origin.x - _scrollView.frame.size.width;
        CGFloat widthDiff = rightSideSpace - newPane.frame.size.width;
        horizontalOffset -= widthDiff;
    }
    
    [_scrollView setContentOffset:CGPointMake(horizontalOffset, 0.0f)
                         animated:animated];
}

- (void)popPaneAtIndex:(NSInteger)index animated:(BOOL)animated
{
    if (index >= 0 && index < [_panes count]) {
        __unsafe_unretained FSPaneView *pane = [_panes objectAtIndex:index];
        
        if (pane.isLoaded) {
            if (animated) {
                [UIView animateWithDuration:0.4f 
                                 animations:^ {
                                     pane.alpha = 0.0f;
                                 }
                                 completion:^(BOOL finished) {
                                     [self _unloadPane:pane remove:YES];
                                     [self _setProperEdgeInset:NO];
                                     // send delegate message
                                     [self didPopPageAtIndex:index];
                                 }];
            }
            else {
                [self _unloadPane:pane remove:YES];
                [self _setProperEdgeInset:NO];
                // send delegate message
                [self didPopPageAtIndex:index];
            }
        }
    }
}

- (void)popAllPanesAnimated:(BOOL)animated
{
    // index of last pane
    NSUInteger index = [_panes count] - 1;
    
    NSEnumerator *enumerator = [_panes reverseObjectEnumerator];
    
    while ([enumerator nextObject]) {
        [self popPaneAtIndex:index animated:NO];
        index--;
    }    
    
    [_panes removeAllObjects];
}

- (void)unloadInvisiblePanes
{
    NSMutableArray *panesToUnload = [NSMutableArray array];
    
    NSArray *visiblePanes = [self visiblePanes];
    
    // if a visible pane exists in array of panes then can't unload
    for (FSPaneView *pane in _panes) {
        if (pane.isLoaded) {
            if ([visiblePanes containsObject:pane] == NO) {
                [panesToUnload addObject:pane];
            }
        }
    }
    
    [panesToUnload enumerateObjectsUsingBlock:^(FSPaneView *pane, NSUInteger idx, BOOL *stop) {
        [self _unloadPane:pane remove:NO];
    }];
}

- (void)layoutSubviews
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation]; 
    
    [self _setProperSizesForLoadedPanes:interfaceOrientation];
    
    [[self visiblePanes] makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

- (void)updateContentLayoutToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [self _setProperContentSize];
    [self _setProperEdgeInset:YES forInterfaceOrientation:interfaceOrientation];
    [self _setProperSizesForLoadedPanes:interfaceOrientation];
}

- (NSInteger)indexOfFirstVisibleView:(BOOL)loadIfNeeded
{
    NSInteger firstVisiblePaneIndex = [self _indexOfFirstVisiblePane];
    
    if ([self _paneExistsAtIndex: firstVisiblePaneIndex]) {
        
        if (loadIfNeeded) {
            // get first visible pane
            FSPaneView *pane = [_panes objectAtIndex:firstVisiblePaneIndex];
            
            // chceck if is loaded, and load if needed
            if (pane.isLoaded == NO) {
                [self _loadPaneAtIndex:firstVisiblePaneIndex];
            }
        }        
        
        return firstVisiblePaneIndex;
    } 
    
    return NSNotFound;
}


- (NSInteger)indexOfLastVisibleView:(BOOL)loadIfNeeded
{
    // calculate visible panes count, first visible and last visible pane
    NSInteger visiblePanesCount = [self _visiblePanesCount];
    NSInteger firstVisiblePaneIndex = [self _indexOfFirstVisiblePane];
    NSInteger lastVisiblePaneIndex = MIN([_panes count]-1, firstVisiblePaneIndex + visiblePanesCount -1);
    return lastVisiblePaneIndex;
}

- (NSArray *)visiblePanes
{
    NSMutableArray *visiblePanes = [NSMutableArray arrayWithCapacity:[_panes count]];
    
    NSInteger firstVisiblePaneIndex = [self _indexOfFirstVisiblePane];
    NSInteger visiblePanesCount = [self _visiblePanesCount];
    
    for (NSInteger i=0; i<=visiblePanesCount + firstVisiblePaneIndex - 1; i++) {
        if ([self _paneExistsAtIndex:i]) {
            FSPaneView *pane = [_panes objectAtIndex:i];
            
            if (pane.isLoaded) {
                if (i < firstVisiblePaneIndex) {
                    if (pane.viewSize == FSViewSizeWider) {
                        [visiblePanes addObject:pane];
                    }
                }
                else {
                    [visiblePanes addObject:pane];
                }
            }
        }
    }
    
    return visiblePanes;
}

#pragma mark -
#pragma mark Private methods
- (NSInteger)_visiblePanesCount
{
    NSInteger firstVisiblePaneIndex = [self _indexOfFirstVisiblePane];
    return ceil((_scrollView.contentOffset.x - firstVisiblePaneIndex * _paneWidth + _paneWidth - _scrollView.contentInset.right) / _paneWidth) + 1;
}

- (NSInteger)_indexOfFirstVisiblePane
{
    // calculate first visible pane
    CGFloat contentOffset = _scrollView.contentOffset.x;// + _scrollView.contentInset.left;
    NSInteger index = floor((contentOffset) / _paneWidth);
    
    return (index < 0) ? 0 : index;
}

- (void)_loadBoundaryPanesIfNeeded
{
    FSPaneView *pane = nil;
    
    NSInteger firstVisiblePaneIndex = [self _indexOfFirstVisiblePane];
    
    if ([self _paneExistsAtIndex:firstVisiblePaneIndex]) {
        // get first visible pane
        pane = [_panes objectAtIndex:firstVisiblePaneIndex];
        
        // load if needed
        if (pane.isLoaded == NO) {
            [self _loadPaneAtIndex:firstVisiblePaneIndex];
        }
        
        NSInteger lastVisiblePaneIndex = [self indexOfLastVisibleView: NO];
        
        if (lastVisiblePaneIndex != firstVisiblePaneIndex) {
            // get last visible pane
            pane = [_panes objectAtIndex:lastVisiblePaneIndex];
            
            // load if needed
            if (pane.isLoaded == NO) {
                [self _loadPaneAtIndex:lastVisiblePaneIndex];
            }
        }
    }
}

- (NSArray *)_panesOnStock
{
    NSInteger firstVisiblePaneIndex = [self _indexOfFirstVisiblePane];
    
    NSMutableArray *panesOnStock = [NSMutableArray arrayWithCapacity:[_panes count]];
    
    for (NSInteger i=0; i<=firstVisiblePaneIndex; i++) {
        if ([self _paneExistsAtIndex:i]) {
            FSPaneView *pane = [_panes objectAtIndex:i];
            [panesOnStock addObject: pane];
        }
    }
    
    return panesOnStock;
}

- (FSPaneView *)_paneAtIndex:(NSInteger)index
{
    if ([self _paneExistsAtIndex:index]) {
        return [_panes objectAtIndex:index];
    }
}

- (BOOL)_paneExistsAtIndex:(NSInteger)index
{
    return index >= 0 && index < [_panes count];
}

- (void)_setProperContentSize
{
//  CGSizeMake(width, UIInterfaceOrientationIsPortrait(interfaceOrientation) ? self.bounds.size.height : self.bounds.size.height);
    CGFloat width = [self _calculateContentWidth];
    _scrollView.contentSize = CGSizeMake(width, 0.0f);
}

- (CGFloat)_calculateContentWidth
{
    NSInteger panesCount = [_panes count] - 1;
    return panesCount * _paneWidth;
}

- (void)_setProperEdgeInset:(BOOL)animated
{
    UIInterfaceOrientation interfaceOrienation = [[UIApplication sharedApplication] statusBarOrientation];
    [self _setProperEdgeInset:animated forInterfaceOrientation:interfaceOrienation];
}

- (void)_setProperEdgeInset:(BOOL)animated forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (animated) {
        [UIView animateWithDuration:0.4
                         animations:^{
            _scrollView.contentInset = [self _calculateEdgeInset:interfaceOrientation];   
        }];
    }
    else {
        _scrollView.contentInset = [self _calculateEdgeInset:interfaceOrientation];   
    }
}

- (UIEdgeInsets)_calculateEdgeInset:(UIInterfaceOrientation)interfaceOrientation
{
    CGFloat leftInset = CATEGORIES_VIEW_WIDTH - _leftInset;
    CGFloat rightInset = 0.0f;
    
    // right inset depends on interface orientation and panes count
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        if ([_panes count] > 1) {
            rightInset = 2 * _paneWidth + _leftInset - self.bounds.size.width;
        }
        else {
            rightInset = _scrollView.bounds.size.width;
        }
    }
    
    return UIEdgeInsetsMake(0.0f, leftInset, 0.0f, rightInset);
}

- (void)_unloadInvisiblePanesOnStock
{
    NSArray *panesOnStock = [self _panesOnStock];
    
    __block NSUInteger lastIndex = [panesOnStock count] -1;
    
    [panesOnStock enumerateObjectsUsingBlock:^(FSPaneView *pane, NSUInteger idx, BOOL *stop) {
        // if item is loaded and is not last pane (first visible pane on stock)
        if (pane.isLoaded && idx != lastIndex) {
            [self _unloadPane:pane remove:NO];
        }
    }];
}

- (FSPaneView *)_createPaneWithView:(UIView*)view size:(FSViewSize)viewSize
{
    FSPaneView *pane = [[FSPaneView alloc] initWithSize:viewSize];
    pane.showRoundedCorners = YES;
    [pane setAutoresizingMask:
     UIViewAutoresizingFlexibleLeftMargin |
     UIViewAutoresizingFlexibleRightMargin |
     UIViewAutoresizingFlexibleBottomMargin |
     UIViewAutoresizingFlexibleTopMargin |
     UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleHeight];
    pane.contentView = view;

    return pane;
}

- (FSPaneView *)_loadPaneAtIndex:(NSInteger)index
{
    FSPaneView *pane = nil; // nil == index out of range
    
    if ([self _paneExistsAtIndex:index]) {
        pane = [_panes objectAtIndex:index];
        
        // rebuild pane if necessery
        if (pane.contentView == nil) {
            UIView *contentView = [_dataSource cascadeView:self pageAtIndex:index];
            
            if (contentView != nil) {
                // preventive, set frame
                CGSize paneSize = [self _calculatePaneSize:pane];
                CGRect paneFrame = CGRectMake(index * _paneWidth, 0.0f, paneSize.width, paneSize.height);
                pane.frame = paneFrame;
                
                pane.contentView = contentView;
                
                FSPaneView *paneBelow = [self _paneAtIndex:index-1];
                FSPaneView *paneAbove = [self _paneAtIndex:index+1];
                if (paneBelow.isLoaded && paneAbove.isLoaded) {
                    NSUInteger indexOfPaneAbove = [_scrollView.subviews indexOfObject:paneAbove];
                    [_scrollView insertSubview:pane atIndex:indexOfPaneAbove];
                }
                else if (paneBelow.isLoaded) {
                    [_scrollView insertSubview:pane aboveSubview:paneBelow];
                }
                else if (paneAbove.isLoaded) {
                    [_scrollView insertSubview:pane belowSubview:paneAbove];
                }
                else {
                    [_scrollView addSubview:pane];
                }
                
                // inform delegate
                [self didLoadPage:contentView];
            }
        }
    }
    
    return pane;
}

- (void)_unloadPane:(FSPaneView *)pane remove:(BOOL)remove
{
    if ([_panes containsObject:pane]) {
        // don't unload views wider then normal because they might be visible
        // (unless we want to remove them permanently)
        if (pane.viewSize == FSViewSizeNormal || remove == YES) {
            [pane removeFromSuperview];
            pane.contentView = nil;
            // inform delegate
            [self didUnloadPage:pane];
        }
        
        if (remove == YES) {
            [_panes removeObject:pane];
        }
    }
}

- (CGSize)_calculatePaneSize:(FSPaneView *)pane
{
    CGFloat height = _scrollView.frame.size.height;
    CGFloat width = NAN;
    
    switch (pane.viewSize) {
        case FSViewSizeNormal:
            width = _paneWidth;
            break;
        case FSViewSizeWider:
            width = _widePaneWidth;
            break;
    }
    
    return CGSizeMake(width, height);
}

- (void)_setProperSizesForLoadedPanes:(UIInterfaceOrientation)interfaceOrientation
{
    [_panes enumerateObjectsUsingBlock:^(FSPaneView *pane, NSUInteger idx, BOOL *stop) {
        if (pane.isLoaded) {
            CGRect rect = pane.frame;
            CGPoint point = [self _calculateOriginOfPaneAtIndex:idx];
            CGSize size = [self _calculatePaneSize:pane];
            rect.size = size;
            rect.origin = point;
            [pane setFrame:rect];
            [pane setNeedsLayout];
        }
    }];
}

- (void)_setProperPositionOfPaneAtIndex:(NSInteger)index
{    
    if ([self _paneExistsAtIndex:index]) {
        FSPaneView *pane = [_panes objectAtIndex:index]; 
        
        if (pane.isLoaded) {            
            CGRect rect = [pane frame];
            rect.origin = [self _calculateOriginOfPaneAtIndex:index];
            [pane setFrame:rect];
        }
    }
}

- (CGPoint)_calculateOriginOfPaneAtIndex:(NSInteger)index
{
    return CGPointMake(MAX(0, _paneWidth * index), 0.0f);
}

#pragma mark -
#pragma mark <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.dragging && scrollView.tracking && !scrollView.pagingEnabled) {
        [scrollView setPagingEnabled:YES];
    }
    
    if ([_panes count] == 0) return;
    
    // operations connected with Pull To Detach Panes action
    [self sendDetachDelegateMethodsIfNeeded];
    
    // operations connected with Pane Did Appear/Disappear delegate metgods
    [self sendAppearanceDelegateMethodsIfNeeded];
    
    if (_flags.isDetachPanes) return;
    
    // calculate first visible pane
    NSInteger firstVisiblePaneIndex = [self _indexOfFirstVisiblePane];
    
    // bug fix with bad position of first pane
    if ((firstVisiblePaneIndex == 0) && (-_scrollView.contentOffset.x >= _scrollView.contentInset.left)) {
        // get pane at index
        FSPaneView *pane = [_panes objectAtIndex:firstVisiblePaneIndex];
        if (pane.isLoaded) {
            CGRect rect = [pane frame];
            rect.origin.x = 0;
            [pane setFrame:rect];
        }
    }
    
    [self _loadBoundaryPanesIfNeeded];
    
    // keep panes that are on stock in place
    for (NSInteger i=0; i<=firstVisiblePaneIndex; i++) {
        if ([self _paneExistsAtIndex:i]) {
            FSPaneView *pane = [_panes objectAtIndex:i];
            
            if (pane.isLoaded) {
                CGFloat contentOffset = _scrollView.contentOffset.x;
                
                if (((i == 0) && (contentOffset <= 0)) || ([_panes count] == 1)) {
                    break;
                }
                
                CGRect newFrame = pane.frame;
                
                newFrame.origin.x = contentOffset;
                
                pane.frame = newFrame;
                
                if (i != firstVisiblePaneIndex) {
                    [self _unloadPane:pane remove:NO];
                }
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}

//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//    [scrollView setPagingEnabled:NO];
//}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_flags.isDetachPanes) _flags.isDetachPanes = NO;
    
#ifdef CONTESTED_CASE
    [_scrollView setPagingEnabled: NO];
#endif
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [_scrollView setPagingEnabled: YES];
    [_scrollView setPagingEnabled: NO];
    [_scrollView setScrollEnabled: YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat realContentOffsetX = _scrollView.contentOffset.x + _scrollView.contentInset.left;
    
    if ((_flags.willDetachPanes) && (realContentOffsetX < - _scrollView.frame.size.width * PULL_TO_DETACH_FACTOR)) {
        [self didPullToDetachPages];
    }
    
    if ((_flags.willDetachPanes) && (realContentOffsetX > - _scrollView.frame.size.width * PULL_TO_DETACH_FACTOR)) {
        [self didCancelPullToDetachPages];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    
    NSInteger secondVisiblePaneIndex = [self _indexOfFirstVisiblePane] + 1;
    [self _setProperPositionOfPaneAtIndex: secondVisiblePaneIndex];
}

#pragma mark -
#pragma mark Delegate methods

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didLoadPage:(UIView*)page {
    if ([_delegate respondsToSelector:@selector(cascadeView:didLoadPage:)]) {
        [_delegate cascadeView:self didLoadPage:page];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didAddPage:(UIView*)page animated:(BOOL)animated {
    if ([_delegate respondsToSelector:@selector(cascadeView:didAddPage:animated:)]) {
        [_delegate cascadeView:self didAddPage:page animated:YES];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didPopPageAtIndex:(NSInteger)index {
    if ([_delegate respondsToSelector:@selector(cascadeView:didPopPageAtIndex:)]) {
        [_delegate cascadeView:self didPopPageAtIndex:index];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didUnloadPage:(UIView*)page {
    if ([_delegate respondsToSelector:@selector(cascadeView:didUnloadPage:)]) {
        [_delegate cascadeView:self didUnloadPage:page];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) pageDidAppearAtIndex:(NSInteger)index {
    if (![self _paneExistsAtIndex: index]) return;
    
    //    NSInteger secondVisiblePageIndex = [self indexOfFirstVisiblePage] +1;
    //    [self setProperPositionOfPageAtIndex: secondVisiblePageIndex];
    
    if ([_delegate respondsToSelector:@selector(cascadeView:pageDidAppearAtIndex:)]) {
        [_delegate cascadeView:self pageDidAppearAtIndex:index];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) pageDidDisappearAtIndex:(NSInteger)index {
    if (![self _paneExistsAtIndex: index]) return;
    
    if ([_delegate respondsToSelector:@selector(cascadeView:pageDidDisappearAtIndex:)]) {
        [_delegate cascadeView:self pageDidDisappearAtIndex:index];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didStartPullingToDetachPages {
    _flags.willDetachPanes = YES;
    if ([_delegate respondsToSelector:@selector(cascadeViewDidStartPullingToDetachPages:)]) {
        [_delegate cascadeViewDidStartPullingToDetachPages:self];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didPullToDetachPages {
    _flags.willDetachPanes = NO;
    _flags.isDetachPanes = YES;
    if ([_delegate respondsToSelector:@selector(cascadeViewDidPullToDetachPages:)]) {
        [_delegate cascadeViewDidPullToDetachPages:self];
    }
    
    [self performSelector:@selector(_setProperContentSize) withObject:nil afterDelay:0.3];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didCancelPullToDetachPages {
    _flags.willDetachPanes = NO;
    if ([_delegate respondsToSelector:@selector(cascadeViewDidCancelPullToDetachPages:)]) {
        [_delegate cascadeViewDidCancelPullToDetachPages:self];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) sendAppearanceDelegateMethodsIfNeeded {
    // calculate first visible page
    NSInteger firstVisiblePaneIndex = [self _indexOfFirstVisiblePane];
    
    if (_indexOfFirstVisiblePane > firstVisiblePaneIndex) {
        [self pageDidAppearAtIndex: firstVisiblePaneIndex];
        _indexOfFirstVisiblePane = firstVisiblePaneIndex;
    }
    else if (_indexOfFirstVisiblePane < firstVisiblePaneIndex) {
        [self pageDidDisappearAtIndex: _indexOfFirstVisiblePane];
        _indexOfFirstVisiblePane = firstVisiblePaneIndex;
    }
    
    // calculate last visible page
    NSInteger lastVisiblePaneIndex = [self indexOfLastVisibleView: NO];
    
    if (_indexOfLastVisiblePane < lastVisiblePaneIndex) {
        [self pageDidAppearAtIndex: lastVisiblePaneIndex];
        _indexOfLastVisiblePane = lastVisiblePaneIndex;
    }
    else if (_indexOfLastVisiblePane > lastVisiblePaneIndex) {
        [self pageDidDisappearAtIndex: _indexOfLastVisiblePane];
        _indexOfLastVisiblePane = lastVisiblePaneIndex;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)sendDetachDelegateMethodsIfNeeded
{
    CGFloat realContentOffsetX = _scrollView.contentOffset.x + _scrollView.contentInset.left;
    
    if (!_flags.isDetachPanes) {
        if ((!_flags.willDetachPanes) && (realContentOffsetX < - _scrollView.frame.size.width * PULL_TO_DETACH_FACTOR)) {
            [self didStartPullingToDetachPages];
        }
        
        if ((_flags.willDetachPanes) && (realContentOffsetX > - _scrollView.frame.size.width * PULL_TO_DETACH_FACTOR)) {
            [self didCancelPullToDetachPages];
        }
    }
}

@end
