//
//  UIScrollView+JLRefresh.m
//  JLRefreshDemo
//
//  Created by Jack on 2017/3/3.
//  Copyright © 2017年 mini1. All rights reserved.
//

#import "UIScrollView+JLRefresh.h"
#import "JLRefreshBasis.h"
#import <objc/runtime.h>

@implementation UIScrollView (JLRefresh)

static const char JLHeaderKey = '\a';

- (void)setJl_header:(JLRefreshBasis *)jl_header {
    
    if (jl_header) {
        [self.jl_header removeFromSuperview];
        [self insertSubview:jl_header atIndex:0];
        
        [self willChangeValueForKey:@"jl_header"];
        objc_setAssociatedObject(self, &JLHeaderKey, jl_header, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"jl_header"];
    }
    
}

- (JLRefreshBasis *)jl_header {
    return objc_getAssociatedObject(self, &JLHeaderKey);
}

static const char JLFooterKey = '\b';

- (void)setJl_footer:(JLRefreshBasis *)jl_footer {
    
    if (jl_footer) {
        [self.jl_footer removeFromSuperview];
        [self insertSubview:jl_footer atIndex:0];
        
        [self willChangeValueForKey:@"jl_footer"];
        objc_setAssociatedObject(self, &JLFooterKey, jl_footer, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"jl_footer"];
    }
}

- (JLRefreshBasis *)jl_footer {
    return objc_getAssociatedObject(self, &JLFooterKey);
}

- (void)setJl_offsetY:(CGFloat)jl_offsetY {
    CGPoint contentOff = self.contentOffset;
    contentOff.y = jl_offsetY;
    self.contentOffset = contentOff;
}

- (CGFloat)jl_offsetY {
    return self.contentOffset.y;
}

- (void)setJl_insetTop:(CGFloat)jl_insetTop {
    UIEdgeInsets inset = self.contentInset;
    inset.top = jl_insetTop;
    self.contentInset = inset;
}

- (CGFloat)jl_insetTop {
    return self.contentInset.top;
}

- (void)setJl_insetBottom:(CGFloat)jl_insetBottom {
    UIEdgeInsets inset = self.contentInset;
    inset.bottom = jl_insetBottom;
    self.contentInset = inset;
}

- (CGFloat)jl_insetBottom {
    return self.contentInset.bottom;
}

- (void)setJl_ContentHeight:(CGFloat)jl_ContentHeight {
    CGSize contentSize = self.contentSize;
    contentSize.height = jl_ContentHeight;
    self.contentSize = contentSize;
}

- (CGFloat)jl_ContentHeight {
    return self.contentSize.height;
}

@end
