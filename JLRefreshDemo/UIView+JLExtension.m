//
//  UIView+Extension.m
//  JLRefreshDemo
//
//  Created by Jack on 2017/3/3.
//  Copyright © 2017年 mini1. All rights reserved.
//

#import "UIView+JLExtension.h"

@implementation UIView (JLExtension)

#pragma mark - Frame

- (void)setJl_x:(CGFloat)jl_x {
    CGRect frame = self.frame;
    frame.origin.x = jl_x;
    self.frame = frame;
}

- (CGFloat)jl_x {
    return self.frame.origin.x;
}

- (void)setJl_y:(CGFloat)jl_y {
    CGRect frame = self.frame;
    frame.origin.y = jl_y;
    self.frame = frame;
}

- (CGFloat)jl_y {
    return self.frame.origin.y;
}

- (void)setJl_width:(CGFloat)jl_width {
    CGRect frame = self.frame;
    frame.size.width = jl_width;
    self.frame = frame;
}

- (CGFloat)jl_width {
    return self.frame.size.width;
}

- (void)setJl_height:(CGFloat)jl_height {
    CGRect frame = self.frame;
    frame.size.height = jl_height;
    self.frame = frame;
}

- (CGFloat)jl_height {
    return self.frame.size.height;
}

- (void)setJl_right:(CGFloat)jl_right {
    self.jl_x = jl_right - self.jl_width;
}

- (CGFloat)jl_right {
    return self.jl_x + self.jl_width;
}

- (void)setJl_bottom:(CGFloat)jl_bottom {
    self.jl_y = jl_bottom - self.jl_height;
}

- (CGFloat)jl_bottom {
    return self.jl_y + self.jl_height;
}

@end
