//
//  FSPanesSplitView.h
//  FSPanes
//
//  Created by Emil Wojtaszek on 11-03-27.
//  Copyright 2011 CreativeLabs.pl
//
//  Modified by Błażej Biesiada, Karol S. Mazur
//  Copyright 2012 Future Simple Inc.
//
//  Licensed under the Apache License, Version 2.0.
//

#import <UIKit/UIKit.h>

@class FSPanesSplitViewController;


@interface FSPanesSplitView : UIView {
    UIView*     _dividerView;
    CGFloat     _dividerWidth;    
}

@property (nonatomic, strong) IBOutlet FSPanesSplitViewController* splitViewController;

@property (nonatomic, strong) UIImage* verticalDividerImage;

@property (nonatomic, strong) UIView* backgroundView;

@property (nonatomic, strong) UIView* menuView;

@property (nonatomic, strong) UIView* navigationView;

@end
