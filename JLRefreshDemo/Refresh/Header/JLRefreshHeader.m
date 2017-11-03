//
//  JLRefreshHeader.m
//  JLRefreshDemo
//
//  Created by Jack on 2017/3/6.
//  Copyright © 2017年 mini1. All rights reserved.
//

#import "JLRefreshHeader.h"

@interface JLRefreshHeader ()

@property (nonatomic,strong) NSMutableDictionary *stateTitle;

@property (nonatomic,strong) UILabel *refreshTitleLabel;

@end

@implementation JLRefreshHeader

#pragma mark - private

- (NSMutableDictionary *)stateTitle {
    if (!_stateTitle) {
        _stateTitle = [@{
                         @(JLRefreshStateIdle)          : @"pull to refresh",
                         @(JLRefreshStatePulling)       : @"pull to refresh",
                         @(JLRefreshStateWillRefresh)   : @"loosen to refresh",
                         @(JLRefreshStateRefreshing)    : @"loading..."
                         } mutableCopy];
    }
    return _stateTitle;
}

- (void)setRefreshTitleForState:(JLRefreshState)state {
    self.refreshTitleLabel.text = [self refreshTitleForState:state];
    [self setNeedsLayout];
}

#pragma mark - override

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.jl_y = -self.jl_height;
    
    [self.refreshTitleLabel sizeToFit];
    CGRect frame = self.refreshTitleLabel.bounds;
    CGFloat Y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(frame)) * 0.5;
    CGFloat X = (CGRectGetWidth(self.bounds) - CGRectGetWidth(frame)) * 0.5;
    self.refreshTitleLabel.jl_y = Y;
    self.refreshTitleLabel.jl_x = X;
    
    [self addSubview:self.refreshTitleLabel];
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary<NSKeyValueChangeKey,id> *)change {
    // 正在刷新
    if (self.state == JLRefreshStateRefreshing) {
        
        // 解决SectionHeader停留
        CGFloat insetTop = -self.scrollView.jl_offsetY > self.scrollViewOriginInsetTop ? -self.scrollView.jl_offsetY : self.scrollViewOriginInsetTop;
        insetTop = insetTop > self.jl_height + self.scrollViewOriginInsetTop ? self.jl_height + self.scrollViewOriginInsetTop : insetTop;
        self.scrollView.jl_insetTop = insetTop;
        
        return;
    }
    
    CGFloat offsetY = self.scrollView.jl_offsetY;
    CGFloat startY = -self.scrollView.jl_insetTop; // refresh 开始显示的临界点
    
    if (offsetY > startY) {
        return;
    }
    
    CGFloat idle2willRefreshY = startY - self.jl_height; // 正常状态到即将刷新状态临界点
    
    if (self.scrollView.isDragging) {
        
        if (self.state == JLRefreshStateIdle && offsetY < startY) {
            
            self.state = JLRefreshStatePulling;
            
        } else if (self.state == JLRefreshStatePulling && offsetY <= idle2willRefreshY) {
            
            self.state = JLRefreshStateWillRefresh;
            
        } else if (self.state == JLRefreshStatePulling && offsetY > startY) {
            
            self.state = JLRefreshStateIdle;
            
        } else if (self.state == JLRefreshStateWillRefresh && offsetY > idle2willRefreshY) {
            
            self.state = JLRefreshStatePulling;
        
        }
        
        float percentage = (startY - offsetY) / self.jl_height;
        if (percentage <= 0) {
            percentage = 0;
        }
        self.pullPercentage = percentage;
        
        if (self.refreshDelegate && [self.refreshDelegate respondsToSelector:@selector(jl_pullRefresh:state:percentage:)]) {
            [self.refreshDelegate jl_pullRefresh:self state:self.state percentage:self.pullPercentage];
        }
        
    }

}

- (void)scrollViewPanGestureStateDidChange:(NSDictionary<NSKeyValueChangeKey,id> *)change {
    if (self.pan.state == UIGestureRecognizerStateEnded && self.state == JLRefreshStateWillRefresh) {
        // 手松开开始刷新
        self.state = JLRefreshStateRefreshing;
    }
}

- (void)setState:(JLRefreshState)state {
    JLRefreshState oldState = self.state;
    
    if (state == oldState) {
        return;
    }
    
    super.state = state;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setRefreshTitleForState:state];
    });
    
    if (state == JLRefreshStateIdle) {

        // 恢复原状态
        if (oldState != JLRefreshStateRefreshing) {
            return;
        }
        
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:JLRefreshDuration animations:^{
                
                weakself.scrollView.jl_insetTop = weakself.scrollViewOriginInsetTop;
                
            } completion:^(BOOL finished) {
                
                if (weakself.refreshDelegate && [weakself.refreshDelegate respondsToSelector:@selector(jl_endRefresh:)]) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakself.refreshDelegate jl_endRefresh:weakself];
                    });
                    
                }
                
            }];
        });

        
        
        
    } else if (state == JLRefreshStatePulling) {
        // 下拉刷新
        
    } else if (state == JLRefreshStateWillRefresh) {
        // 松开刷新
        
    } else if (state == JLRefreshStateRefreshing) {
        // 正在刷新
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:JLRefreshDuration animations:^{
                
                weakself.scrollView.jl_insetTop = weakself.jl_height;
                
            } completion:^(BOOL finished) {
                
                if (weakself.refreshDelegate && [weakself.refreshDelegate respondsToSelector:@selector(jl_beginRefresh:)]) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakself.refreshDelegate jl_beginRefresh:weakself];
                    });
                    
                }
                
            }];
            
        });

    }
}

#pragma mark - Public

- (void)setRefreshTitle:(NSString *)title forState:(JLRefreshState)state {
    if (title == nil) {
        return;
    }
    
    [self.stateTitle setObject:title forKey:@(state)];
}

- (NSString *)refreshTitleForState:(JLRefreshState)state {
    return [self.stateTitle objectForKey:@(state)];
}

#pragma mark - SubView

- (UILabel *)refreshTitleLabel {
    if (!_refreshTitleLabel) {
        _refreshTitleLabel = [[UILabel alloc] init];
        _refreshTitleLabel.textAlignment = NSTextAlignmentCenter;
        _refreshTitleLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    return _refreshTitleLabel;
}


@end
