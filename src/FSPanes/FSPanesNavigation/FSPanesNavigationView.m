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

#define UISCROLL_OFFSET_RANGE_BUG_FIX 0.001f
#define PAGING_VELOCITY_LIMIT 0.1f

@interface FSPanesNavigationView (DelegateMethods)

- (void)didLoadPane:(FSPaneView *)pane;
- (void)didAddPane:(FSPaneView *)pane animated:(BOOL)animated;
- (void)didPopPaneAtIndex:(NSInteger)index;
- (void)didUnloadPane:(FSPaneView *)pane;
- (void)paneDidAppearAtIndex:(NSInteger)index;
- (void)paneDidDisappearAtIndex:(NSInteger)index;
- (void)didStartPullingToDetachPanes;
- (void)didPullToDetachPanes;
- (void)didCancelPullToDetachPanes;
- (void)sendAppearanceDelegateMethodsIfNeeded;
- (void)sendDetachDelegateMethodsIfNeeded;

@end

@interface FSPanesNavigationView ()
{
    FSPanesNavigationScrollView *_scrollView;
    
    NSMutableArray *_panes;
    
    CGFloat _paneWidth;
    CGFloat _widePaneWidth;
    CGFloat _leftInset;
    CGFloat _widerLeftInset;
    
    struct {
        unsigned int willDetachPanes:1;
        unsigned int isDetachingPanes:1;
    } _flags;
    
    NSInteger _indexOfFirstVisiblePane;
    NSInteger _indexOfLastVisiblePane;
}

- (NSArray *)_panesOnStack;

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

- (FSPaneView *)_createPaneWithView:(UIView*)view size:(FSPaneSize)viewSize;
- (FSPaneView *)_loadPaneAtIndex:(NSInteger)index;
- (void)_unloadPane:(FSPaneView*)pane remove:(BOOL)remove;
- (void)_loadBoundaryPanesIfNeeded;

- (NSInteger)_indexOfFirstVisiblePane;
- (NSInteger)_visiblePanesCount;

- (void)_setProperPositionOfPaneAtIndex:(NSInteger)index;

@end

@implementation FSPanesNavigationView

@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;

@synthesize leftInset = _leftInset; 
@synthesize widerLeftInset = _widerLeftInset;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _panes = [[NSMutableArray alloc] initWithCapacity:8];
        
        _flags.willDetachPanes = NO;
        _flags.isDetachingPanes = NO;
        
        _indexOfFirstVisiblePane = -1;
        _indexOfLastVisiblePane = -1;
        
        _scrollView = [[FSPanesNavigationScrollView alloc] init]; // frame will be set in setter of _leftInset
        [_scrollView setDelegate:self];
        
        self.leftInset = DEFAULT_LEFT_INSET;
        self.widerLeftInset = DEFAULT_WIDER_LEFT_INSET;
        
        [self addSubview:_scrollView];
        
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

- (void)layoutSubviews
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation]; 
    
    [self _setProperSizesForLoadedPanes:interfaceOrientation];
    
    [[self visiblePanes] makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

#pragma mark -
#pragma mark FSPanesNavigationView
- (void)pushView:(UIView *)newView animated:(BOOL)animated
{
    [self pushView:newView animated:animated viewSize:FSPaneSizeRegular];
}

- (void)pushView:(UIView *)newView animated:(BOOL)animated viewSize:(FSPaneSize)viewSize
{
    FSPaneView *newPane = [self _createPaneWithView:newView size:viewSize];
    
    NSUInteger newPaneIndex = [_panes count];
    
    CGSize paneSize = [self _calculatePaneSize:newPane];
    CGPoint paneOrigin = [self _calculateOriginOfPaneAtIndex:newPaneIndex];
    CGRect paneFrame = {.origin = paneOrigin, .size = paneSize};
    
    // animation of inserting a new root pane (from left to right)
    if (animated && newPaneIndex == 0 && _scrollView.contentOffset.x >= 0) {
        CGRect initialAnimationFrame = CGRectMake(paneOrigin.x - paneSize.width, paneOrigin.y, paneSize.width, paneSize.height);
        newPane.frame = initialAnimationFrame;
        
        [UIView animateWithDuration:0.15 
                         animations:^ {
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
    [self didAddPane:newPane animated:animated];
    
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

- (void)replaceViewAtIndex:(NSUInteger)oldViewIndex withView:(UIView *)newView viewSize:(FSPaneSize)viewSize
{
    if ([self _paneExistsAtIndex:oldViewIndex] && [newView isKindOfClass:[UIView class]]) {
        // remove old
        FSPaneView *oldPane = [_panes objectAtIndex:oldViewIndex];
        [self _unloadPane:oldPane remove:YES];
        [self didPopPaneAtIndex:oldViewIndex];
        
        // add new
        [self pushView:newView animated:NO viewSize:viewSize];
    }
}

- (void)popPaneAtIndex:(NSInteger)index animated:(BOOL)animated
{
    if ([self _paneExistsAtIndex:index]) {
        __unsafe_unretained FSPaneView *pane = [_panes objectAtIndex:index];
        
        if (pane.isLoaded) {
            void (^panePopBlock) (BOOL) = ^ (BOOL finished) {
                [self _unloadPane:pane remove:YES];
                if (!_flags.isDetachingPanes) {
                    // beacause content size and insets set during animation would cause glitches
                    [self _setProperEdgeInset:NO];
                    [self _setProperContentSize];
                }
                [self didPopPaneAtIndex:index];
            };
            
            if (animated) {
                [UIView animateWithDuration:0.4f 
                                 animations:^ {
                                     pane.alpha = 0.0f;
                                 }
                                 completion:panePopBlock];
            }
            else {
                panePopBlock(YES);
            }
        }
    }
}

- (void)popAllPanesAnimated:(BOOL)animated
{
    NSUInteger index = [_panes count] - 1; // index of last pane
    
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

- (void)updateContentLayoutToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [self _setProperContentSize];
    [self _setProperEdgeInset:YES forInterfaceOrientation:interfaceOrientation];
    [self _setProperSizesForLoadedPanes:interfaceOrientation];
}

- (NSInteger)indexOfFirstVisibleView:(BOOL)loadIfNeeded
{
    NSInteger firstVisiblePaneIndex = [self _indexOfFirstVisiblePane];
    
    if ([self _paneExistsAtIndex:firstVisiblePaneIndex]) {
        if (loadIfNeeded) {
            FSPaneView *pane = [_panes objectAtIndex:firstVisiblePaneIndex];
            
            if (pane.isLoaded == NO) {
                [self _loadPaneAtIndex:firstVisiblePaneIndex];
            }
        }
    }
    else {
        firstVisiblePaneIndex = NSNotFound;
    }
    
    return firstVisiblePaneIndex;
}

- (NSInteger)indexOfLastVisibleView:(BOOL)loadIfNeeded
{
    NSInteger visiblePanesCount = [self _visiblePanesCount];
    NSInteger firstVisiblePaneIndex = [self _indexOfFirstVisiblePane];
    NSInteger lastVisiblePaneIndex = MIN([_panes count]-1, firstVisiblePaneIndex + visiblePanesCount - 1);
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
                    if (pane.viewSize == FSPaneSizeWide) {
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

#pragma mark Private method definitions

- (NSInteger)_visiblePanesCount
{
    NSInteger firstVisiblePaneIndex = [self _indexOfFirstVisiblePane];
    return ceil((_scrollView.contentOffset.x - firstVisiblePaneIndex * _paneWidth + _paneWidth - _scrollView.contentInset.right) / _paneWidth) + 1;
}

- (NSInteger)_indexOfFirstVisiblePane
{
    CGFloat contentOffset = _scrollView.contentOffset.x;
    NSInteger index = floorf(contentOffset / _paneWidth);
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

- (NSArray *)_panesOnStack
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
    FSPaneView *pane = nil;
    if ([self _paneExistsAtIndex:index]) {
        pane = [_panes objectAtIndex:index];
    }
    return pane;
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
    NSArray *panesOnStock = [self _panesOnStack];
    
    __block NSUInteger lastIndex = [panesOnStock count] -1;
    
    [panesOnStock enumerateObjectsUsingBlock:^(FSPaneView *pane, NSUInteger idx, BOOL *stop) {
        // if item is loaded and is not last pane (first visible pane on stock)
        if (pane.isLoaded && idx != lastIndex) {
            [self _unloadPane:pane remove:NO];
        }
    }];
}

- (FSPaneView *)_createPaneWithView:(UIView*)view size:(FSPaneSize)viewSize
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
            UIView *contentView = [_dataSource navigationView:self viewAtIndex:index];
            
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
                [self didLoadPane:pane];
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
        if (pane.viewSize == FSPaneSizeRegular || remove == YES) {
            [pane removeFromSuperview];
            pane.contentView = nil;
            // inform delegate
            [self didUnloadPane:pane];
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
        case FSPaneSizeRegular:
            width = _paneWidth;
            break;
        case FSPaneSizeWide:
            width = _widePaneWidth;
            break;
    }
    
    return CGSizeMake(width, height);
}

- (void)_setProperSizesForLoadedPanes:(UIInterfaceOrientation)interfaceOrientation
{
    [_panes enumerateObjectsUsingBlock:^(FSPaneView *pane, NSUInteger idx, BOOL *stop) {
        if (pane.isLoaded) {
            CGPoint point = [self _calculateOriginOfPaneAtIndex:idx];
            CGSize size = [self _calculatePaneSize:pane];
            CGRect newFrame = {.origin = point, .size = size };
            pane.frame = newFrame;
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
    CGFloat x;
    NSUInteger indexOfFirstVisiblePane = [self _indexOfFirstVisiblePane];
    
    if (index > indexOfFirstVisiblePane || 
        (index == 0 && index == indexOfFirstVisiblePane && _scrollView.contentOffset.x <= 0)) {
        // if pane/index is on stock then keep it on fixed position
        x = _paneWidth * index;
    }
    else {
        x = _scrollView.contentOffset.x;
    }
    
    return CGPointMake(x, 0.0f);
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_panes count] > 0)
    {
        [self sendDetachDelegateMethodsIfNeeded];
        
        [self sendAppearanceDelegateMethodsIfNeeded];
        
        if (_flags.isDetachingPanes == NO)
        {
            NSInteger firstVisiblePaneIndex = [self _indexOfFirstVisiblePane];
            NSInteger indexOfLastVisibleView = [self indexOfLastVisibleView:NO];
            
            [self _loadBoundaryPanesIfNeeded];
            
            // keep panes that are on stock in place
            if ([_panes count] > 1) {
                for (NSInteger i=0; i<=indexOfLastVisibleView; i++) {
                    FSPaneView *pane = [_panes objectAtIndex:i];
                    
                    if (pane.isLoaded) {
                        CGRect newFrame = pane.frame;
                        newFrame.origin = [self _calculateOriginOfPaneAtIndex:i];
                        pane.frame = newFrame;
                        
                        if (i < firstVisiblePaneIndex) {
                            [self _unloadPane:pane remove:NO];
                        }
                    }
                }
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_flags.isDetachingPanes) {
        _flags.isDetachingPanes = NO;
        
        // beacause content size and insets set during animation would cause glitches
        [self _setProperEdgeInset:NO];
        [self _setProperContentSize];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat realContentOffsetX = _scrollView.contentOffset.x + _scrollView.contentInset.left;
    
    if (_flags.willDetachPanes) {
        if (realContentOffsetX < - _scrollView.frame.size.width * PULL_TO_DETACH_FACTOR) {
            [self didPullToDetachPanes];
        }
        else {
            [self didCancelPullToDetachPanes];
        }
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{    
    NSInteger secondVisiblePaneIndex = [self _indexOfFirstVisiblePane] + 1;
    [self _setProperPositionOfPaneAtIndex: secondVisiblePaneIndex];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat targetOffset = (*targetContentOffset).x;
    CGFloat contentWidth = scrollView.contentSize.width;
    CGFloat leftNeighbor = NAN, rightNeighbor = NAN, newTargetOffset = NAN;
    
    // calculate neighbors to the targetOffset
    if (targetOffset > contentWidth) { // on right inset (or last pane)
        leftNeighbor = contentWidth;
        rightNeighbor = contentWidth + scrollView.contentInset.right - UISCROLL_OFFSET_RANGE_BUG_FIX;
    }
    else if (targetOffset > 0) { // on one of panes
        CGFloat paneIndex = floorf(targetOffset / _paneWidth);
        leftNeighbor = _paneWidth * paneIndex;
        rightNeighbor = _paneWidth * (paneIndex + 1);
    }
    else { // on left inset
        leftNeighbor = -scrollView.contentInset.left + UISCROLL_OFFSET_RANGE_BUG_FIX;
        rightNeighbor = 0.0 - UISCROLL_OFFSET_RANGE_BUG_FIX;
    }
    
    CGFloat maxOffset = contentWidth + scrollView.contentInset.right - scrollView.bounds.size.width - UISCROLL_OFFSET_RANGE_BUG_FIX;
    rightNeighbor = MIN(rightNeighbor, maxOffset);
    
    // based on targetOffset and veliocty decide which neighbor should be the new target
    if (velocity.x > PAGING_VELOCITY_LIMIT) {
        newTargetOffset = rightNeighbor;
    } else if (velocity.x < -PAGING_VELOCITY_LIMIT) {
        newTargetOffset = leftNeighbor;
    }
    else {
        if (rightNeighbor - targetOffset > targetOffset - leftNeighbor) {
            newTargetOffset = leftNeighbor;
        }
        else {
            newTargetOffset = rightNeighbor;
        }
    }
    
    (*targetContentOffset).x = newTargetOffset;
}

#pragma mark FSPanesNavigationView (DelegateMethods)

- (void)didLoadPane:(FSPaneView *)pane
{
    if ([_delegate respondsToSelector:@selector(cascadeView:didLoadPane:)]) {
        [_delegate cascadeView:self didLoadPane:pane];
    }
}

- (void)didAddPane:(FSPaneView *)pane animated:(BOOL)animated
{
    if ([_delegate respondsToSelector:@selector(cascadeView:didAddPane:animated:)]) {
        [_delegate cascadeView:self didAddPane:pane animated:YES];
    }
}

- (void)didPopPaneAtIndex:(NSInteger)index
{
    if ([_delegate respondsToSelector:@selector(cascadeView:didPopPaneAtIndex:)]) {
        [_delegate cascadeView:self didPopPaneAtIndex:index];
    }
}

- (void)didUnloadPane:(FSPaneView *)pane
{
    if ([_delegate respondsToSelector:@selector(cascadeView:didUnloadPane:)]) {
        [_delegate cascadeView:self didUnloadPane:pane];
    }
}

- (void)paneDidAppearAtIndex:(NSInteger)index
{
    if ([self _paneExistsAtIndex: index]) 
    {
        //    NSInteger secondVisiblePageIndex = [self indexOfFirstVisiblePage] +1;
        //    [self setProperPositionOfPageAtIndex: secondVisiblePageIndex];
        
        if ([_delegate respondsToSelector:@selector(cascadeView:paneDidAppearAtIndex:)]) {
            [_delegate cascadeView:self paneDidAppearAtIndex:index];
        }
    }
}

- (void)paneDidDisappearAtIndex:(NSInteger)index
{
    if ([self _paneExistsAtIndex: index]) {
        if ([_delegate respondsToSelector:@selector(cascadeView:paneDidDisappearAtIndex:)]) {
            [_delegate cascadeView:self paneDidDisappearAtIndex:index];
        }
    }
}

- (void)didStartPullingToDetachPanes
{
    _flags.willDetachPanes = YES;
    
    if ([_delegate respondsToSelector:@selector(navigationViewDidStartPullingToDetachPanes:)]) {
        [_delegate navigationViewDidStartPullingToDetachPanes:self];
    }
}

- (void)didPullToDetachPanes
{
    _flags.willDetachPanes = NO;
    _flags.isDetachingPanes = YES;
    
    if ([_delegate respondsToSelector:@selector(navigationViewDidPullToDetachPanes:)]) {
        [_delegate navigationViewDidPullToDetachPanes:self];
    }
    
    for (int paneIndex = [_panes count]-1; paneIndex > 0; paneIndex--) {
        [self popPaneAtIndex:paneIndex animated:NO];
    }
}

- (void)didCancelPullToDetachPanes
{
    _flags.willDetachPanes = NO;
    
    if ([_delegate respondsToSelector:@selector(navigationViewDidCancelPullToDetachPanes:)]) {
        [_delegate navigationViewDidCancelPullToDetachPanes:self];
    }
}

- (void)sendAppearanceDelegateMethodsIfNeeded
{
    NSInteger firstVisiblePaneIndex = [self _indexOfFirstVisiblePane];
    
    if (_indexOfFirstVisiblePane > firstVisiblePaneIndex) {
        [self paneDidAppearAtIndex:firstVisiblePaneIndex];
        _indexOfFirstVisiblePane = firstVisiblePaneIndex;
    }
    else if (_indexOfFirstVisiblePane < firstVisiblePaneIndex) {
        [self paneDidDisappearAtIndex:_indexOfFirstVisiblePane];
        _indexOfFirstVisiblePane = firstVisiblePaneIndex;
    }
    
    NSInteger lastVisiblePaneIndex = [self indexOfLastVisibleView: NO];
    
    if (_indexOfLastVisiblePane < lastVisiblePaneIndex) {
        [self paneDidAppearAtIndex:lastVisiblePaneIndex];
        _indexOfLastVisiblePane = lastVisiblePaneIndex;
    }
    else if (_indexOfLastVisiblePane > lastVisiblePaneIndex) {
        [self paneDidDisappearAtIndex:_indexOfLastVisiblePane];
        _indexOfLastVisiblePane = lastVisiblePaneIndex;
    }
}

- (void)sendDetachDelegateMethodsIfNeeded
{
    CGFloat realContentOffsetX = _scrollView.contentOffset.x + _scrollView.contentInset.left;
    
    if (!_flags.isDetachingPanes) {
        if ((!_flags.willDetachPanes) && (realContentOffsetX < - _scrollView.frame.size.width * PULL_TO_DETACH_FACTOR)) {
            [self didStartPullingToDetachPanes];
        }
        
        if ((_flags.willDetachPanes) && (realContentOffsetX > - _scrollView.frame.size.width * PULL_TO_DETACH_FACTOR)) {
            [self didCancelPullToDetachPanes];
        }
    }
}

@end
