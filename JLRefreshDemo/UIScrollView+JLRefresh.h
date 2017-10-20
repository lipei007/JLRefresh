//
//  UIScrollView+JLRefresh.h
//  JLRefreshDemo
//
//  Created by Jack on 2017/3/3.
//  Copyright © 2017年 mini1. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JLRefreshBasis;

@interface UIScrollView (JLRefresh)

@property (nonatomic,strong) JLRefreshBasis *jl_header;

@property (nonatomic,strong) JLRefreshBasis *jl_footer;

@property (nonatomic,assign) CGFloat jl_offsetY;

@property (nonatomic,assign) CGFloat jl_insetTop;

@property (nonatomic,assign) CGFloat jl_insetBottom;

@property (nonatomic,assign) CGFloat jl_ContentHeight;

@end
