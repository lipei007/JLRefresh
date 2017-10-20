//
//  JLRefreshFooter.m
//  JLRefreshDemo
//
//  Created by Jack on 2017/3/7.
//  Copyright © 2017年 mini1. All rights reserved.
//

#import "JLRefreshFooter.h"

@interface JLRefreshFooter ()

@end

@implementation JLRefreshFooter

#pragma mark - Private

- (BOOL)contentSizeIsOutOfScrollViewBounds {
    // top + content > height
    return self.scrollView.jl_insetTop + self.scrollView.jl_ContentHeight > self.scrollView.jl_height;
}

#pragma mark - Override

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview) { // add
        
        self.scrollView.jl_insetBottom += self.jl_height;
        
        self.jl_y = self.scrollView.jl_ContentHeight;
    
    } else { // remove
        
        self.scrollView.jl_insetBottom -= self.jl_height;
        
    }
    
}

- (void)scrollViewContentSizeDidChange:(NSDictionary<NSKeyValueChangeKey,id> *)change {
    
    [super scrollViewContentSizeDidChange:change];
    
    self.jl_y = self.scrollView.jl_ContentHeight;
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary<NSKeyValueChangeKey,id> *)change {
    
    [super scrollViewContentOffsetDidChange:change];

    if (self.state == JLRefreshStateRefreshing) {
        return;
    }
    
    CGFloat offsetY = self.scrollView.jl_offsetY + self.scrollView.jl_height;
    CGFloat startY = self.scrollView.jl_insetBottom + self.scrollView.jl_ContentHeight - self.jl_height;
    CGFloat idle2WillRefresh = startY + self.jl_height;
    
    if ([self contentSizeIsOutOfScrollViewBounds]) {
        
        
        if (offsetY < startY) {
            return;
        }
       
        
        if (self.scrollView.isDragging) {
            
            if (self.state == JLRefreshStateIdle) { // 1
                
                self.state = JLRefreshStatePulling; // 2
                
            } else if (self.state == JLRefreshStatePulling && offsetY < startY) {
                
                self.state = JLRefreshStateIdle;
                
            } else if (self.state == JLRefreshStatePulling && offsetY >= idle2WillRefresh) { // 完全显示出来才刷新
                
                self.state = JLRefreshStateWillRefresh; // 4
                
            }
            
           
            
        } else {
            
            // 停止拖动的减速过程
            if (self.state != JLRefreshStateRefreshing && offsetY >= idle2WillRefresh) {
                self.state = JLRefreshStateRefreshing;
            }
            
        }
        
        float percentage = (offsetY - startY) / self.jl_height;
        if (percentage < 0) {
            percentage = 0;
        }
        self.pullPercentage = percentage;
        
        if (self.refreshDelegate && [self.refreshDelegate respondsToSelector:@selector(jl_pullRefresh:state:percentage:)]) {
            [self.refreshDelegate jl_pullRefresh:self state:self.state percentage:self.pullPercentage];
        }
        
    } else {
        
        CGPoint old = [change[@"old"] CGPointValue];
        CGPoint new = [change[@"new"] CGPointValue];
        
        if (self.scrollView.jl_insetTop == self.scrollViewOriginInsetTop && new.y > -self.scrollViewOriginInsetTop && old.y < new.y) { // 上拉,在未超出height的范围内拖动都视为刷新
            
            if (self.state == JLRefreshStateRefreshing) return;
            
            self.state = JLRefreshStateWillRefresh;
            self.pullPercentage = 1;
            
            if (self.refreshDelegate && [self.refreshDelegate respondsToSelector:@selector(jl_pullRefresh:state:percentage:)]) {
                [self.refreshDelegate jl_pullRefresh:self state:self.state percentage:self.pullPercentage];
            }
        }

        
    }
    
    
    
    
}

- (void)scrollViewPanGestureStateDidChange:(NSDictionary<NSKeyValueChangeKey,id> *)change {
    
    [super scrollViewPanGestureStateDidChange:change];
    
    if (self.pan.state == UIGestureRecognizerStateEnded) {
        
        if (self.state == JLRefreshStateWillRefresh) {
            self.state = JLRefreshStateRefreshing;
        }
        
        
    }
    
}

#pragma mark - Setter

- (void)setState:(JLRefreshState)state {
    
    JLRefreshState oldState = self.state;
    
    if (state == oldState) {
        return;
    }
    
    super.state = state;

     __weak typeof(self) weakself = self;
    
    if (state == JLRefreshStateIdle || state == JLRefreshStateNoMore) {
        
        if (oldState != JLRefreshStateRefreshing) {
            return;
        }
        
        if (weakself.refreshDelegate && [weakself.refreshDelegate respondsToSelector:@selector(jl_endRefresh:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.refreshDelegate jl_endRefresh:weakself];
            });
            
        }
        
    } else if (state == JLRefreshStatePulling) {
        
        
    } else if (state == JLRefreshStateWillRefresh) {
        
        
    } else if (state == JLRefreshStateRefreshing) {
        
        if (weakself.refreshDelegate && [weakself.refreshDelegate respondsToSelector:@selector(jl_beginRefresh:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.refreshDelegate jl_beginRefresh:weakself];
            });
            
        }
        
    }
    
}

#pragma mark - Public

- (void)noMoreData {
    self.state = JLRefreshStateNoMore;
}


@end
