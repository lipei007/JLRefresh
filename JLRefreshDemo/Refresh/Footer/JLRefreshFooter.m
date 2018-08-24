//
//  JLRefreshFooter.m
//  JLRefreshDemo
//
//  Created by Jack on 2017/3/7.
//  Copyright © 2017年 mini1. All rights reserved.
//

#import "JLRefreshFooter.h"

@interface JLRefreshFooter ()

@property (nonatomic,strong) NSMutableDictionary *stateTitle;
@property (nonatomic,strong) UILabel *refreshTitleLabel;
@property (nonatomic,assign) BOOL stopWithNomore;

@end

@implementation JLRefreshFooter

#pragma mark - SubView

- (UILabel *)refreshTitleLabel {
    if (!_refreshTitleLabel) {
        _refreshTitleLabel = [[UILabel alloc] init];
        _refreshTitleLabel.textAlignment = NSTextAlignmentCenter;
        _refreshTitleLabel.font = [UIFont systemFontOfSize:14.0f];
        _refreshTitleLabel.hidden = NO;
    }
    return _refreshTitleLabel;
}

#pragma mark - Private

- (BOOL)contentSizeIsOutOfScrollViewBounds {
    // top + content > height
    return self.scrollView.jl_insetTop + self.scrollView.jl_ContentHeight > self.scrollView.jl_height;
}

- (NSMutableDictionary *)stateTitle {
    if (!_stateTitle) {
        _stateTitle = [@{
                         @(JLRefreshStateIdle)          : @"pull to load more",
                         @(JLRefreshStatePulling)       : @"will load More",
                         @(JLRefreshStateWillRefresh)   : @"loosen to load more",
                         @(JLRefreshStateRefreshing)    : @"loading...",
                         @(JLRefreshStateNoMore)        : @"no more"
                         } mutableCopy];
    }
    return _stateTitle;
}

- (void)setRefreshTitleForState:(JLRefreshState)state {
    self.refreshTitleLabel.text = [self refreshTitleForState:state];
    [self setNeedsLayout];
}


#pragma mark - Override

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    [self.refreshTitleLabel sizeToFit];
    CGRect frame = self.refreshTitleLabel.bounds;
    CGFloat Y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(frame)) * 0.5;
    CGFloat X = (CGRectGetWidth(self.bounds) - CGRectGetWidth(frame)) * 0.5;
    self.refreshTitleLabel.jl_y = Y;
    self.refreshTitleLabel.jl_x = X;
    
    [self addSubview:self.refreshTitleLabel];
    
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
    CGFloat idle2WillRefresh = startY + self.jl_height * 1.5;
    
    if ([self contentSizeIsOutOfScrollViewBounds]) {
        
        
        if (offsetY < startY) {
            return;
        }
       
        
        if (self.scrollView.isDragging) {
            if (self.state == JLRefreshStateNoMore) {
                
                self.state = JLRefreshStateIdle;
                
            } else if (self.state == JLRefreshStateIdle) { // 1
                
                self.state = JLRefreshStatePulling; // 2
                
            } else if (self.state == JLRefreshStatePulling && offsetY < startY) {
                
                self.state = JLRefreshStateIdle;
                
            } else if (self.state == JLRefreshStatePulling && offsetY >= idle2WillRefresh) { // 完全显示出来才刷新
                
                self.state = JLRefreshStateWillRefresh; // 4
                
            } else if (self.state == JLRefreshStateWillRefresh && offsetY < idle2WillRefresh) {
                self.state = JLRefreshStatePulling; 
            }
            
           
            
        } else {
            
            // 停止拖动的减速过程
            if (self.state != JLRefreshStateRefreshing && offsetY >= idle2WillRefresh) {
                self.state = JLRefreshStateRefreshing;
            } else {
                if (self.stopWithNomore) {
                    [self setState:JLRefreshStateNoMore];
                }
                if (self.state != JLRefreshStateNoMore) {
                    self.state = JLRefreshStateIdle;
                }
            }
            
        }
        
        float percentage = (offsetY - startY) / self.jl_height;
        if (percentage < 0) {
            percentage = 0;
        }
        self.pullPercentage = percentage;
        
        [self showTip];
        if (self.refreshDelegate && [self.refreshDelegate respondsToSelector:@selector(jl_pullRefresh:state:percentage:)]) {
            [self.refreshDelegate jl_pullRefresh:self state:self.state percentage:self.pullPercentage];
        }
        
        
    } else {
        
        CGPoint old = [change[@"old"] CGPointValue];
        CGPoint new = [change[@"new"] CGPointValue];
        
        if (self.scrollView.jl_insetTop == self.scrollViewOriginInsetTop && new.y > -self.scrollViewOriginInsetTop && old.y < new.y) { // 上拉,在未超出height的范围内拖动都视为刷新
            
            if (self.state == JLRefreshStateRefreshing) return;
            
            if (self.scrollView.isDragging) {
                self.state = JLRefreshStateWillRefresh;
                self.pullPercentage = 1;
                [self showTip];
                if (self.refreshDelegate && [self.refreshDelegate respondsToSelector:@selector(jl_pullRefresh:state:percentage:)]) {
                    [self.refreshDelegate jl_pullRefresh:self state:self.state percentage:self.pullPercentage];
                }
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself setRefreshTitleForState:state];
    });

    
    
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
                weakself.stopWithNomore = NO;
                [weakself.refreshDelegate jl_beginRefresh:weakself];
            });
            
        }
        
    }
    
}

#pragma mark - Public

- (void)noMoreData {
    self.state = JLRefreshStateNoMore;
    if (self.scrollView.isDecelerating) {
        self.stopWithNomore = YES; // Scrollviewc重新刷新数据后才能赋值NO
    }
}

- (void)showTip {
    self.refreshTitleLabel.hidden = NO;
}

- (void)setRefreshTitle:(NSString *)title forState:(JLRefreshState)state {
    if (title == nil) {
        return;
    }
    
    [self.stateTitle setObject:title forKey:@(state)];
}

- (NSString *)refreshTitleForState:(JLRefreshState)state {
    return [self.stateTitle objectForKey:@(state)];
}



@end
