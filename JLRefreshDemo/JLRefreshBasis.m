//
//  JLRefresh.m
//  JLRefreshDemo
//
//  Created by Jack on 2017/3/3.
//  Copyright © 2017年 mini1. All rights reserved.
//

#import "JLRefreshBasis.h"

NSTimeInterval const JLRefreshDuration = 0.25;
CGFloat const JLRefreshHeight = 64;
NSString *const JLRefreshKeyPathContentOffset = @"contentOffset";
NSString *const JLRefreshKeyPathContentSize = @"contentSize";
NSString *const JLRefreshKeyPathContentInset = @"contentInset";
NSString *const JLRefreshKeyPathState = @"state";

@interface JLRefreshBasis ()
{
    __weak UIScrollView *_scrollView;
    UIPanGestureRecognizer *_pan;
}

@property (nonatomic,assign) CGFloat scrollViewOriginInsetTop;
@property (nonatomic,assign) CGFloat scrollViewOriginInsetBottom;

@end

@implementation JLRefreshBasis

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self prepareInterface];
        self.state = JLRefreshStateIdle;
    }
    return self;
}

- (void)prepareInterface {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor clearColor];
    self.jl_height = JLRefreshHeight;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.jl_width = CGRectGetWidth(self.superview.frame);
}

- (void)dealloc {
    [self resignObserver];
}

/**添加观察者*/
- (void)registObserver {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    
    [_scrollView addObserver:self forKeyPath:JLRefreshKeyPathContentOffset options:options context:nil];
    [_scrollView addObserver:self forKeyPath:JLRefreshKeyPathContentSize options:options context:nil];
    [_scrollView addObserver:self forKeyPath:JLRefreshKeyPathState options:options context:nil];
    _pan = _scrollView.panGestureRecognizer;
    [_pan addObserver:self forKeyPath:JLRefreshKeyPathState options:options context:nil];
    
}

/**移除观察者*/
- (void)resignObserver {
    
    [_scrollView removeObserver:self forKeyPath:JLRefreshKeyPathContentOffset];
    [_scrollView removeObserver:self forKeyPath:JLRefreshKeyPathContentSize];
    [_scrollView removeObserver:self forKeyPath:JLRefreshKeyPathState];
    [_pan removeObserver:self forKeyPath:JLRefreshKeyPathState];
    _pan = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    [self resignObserver];
    // 父控件不是ScrollView，不做设置
    if (newSuperview && ![newSuperview isKindOfClass:[UIScrollView class]]) {
        _scrollView = nil;
        return;
    }

    _scrollView = (UIScrollView *)newSuperview;
    _scrollView.alwaysBounceVertical = YES; // 永远支持垂直弹簧效果
    
    self.state = JLRefreshStateIdle;
        
    self.scrollViewOriginInsetTop = _scrollView.jl_insetTop;
    self.scrollViewOriginInsetBottom = _scrollView.jl_insetBottom;
    
    [self registObserver];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (!self.isUserInteractionEnabled) {
        return;
    }
    
    if (keyPath == JLRefreshKeyPathContentSize) {
        [self scrollViewContentSizeDidChange:change];
    }
    
    if (self.hidden) {
        return;
    }
    
    if (keyPath == JLRefreshKeyPathContentOffset) {
        [self scrollViewContentOffsetDidChange:change];
    }
    
    
    if (keyPath == JLRefreshKeyPathState) {
        [self scrollViewPanGestureStateDidChange:change];
    }
    
}

- (void)scrollViewContentSizeDidChange:(NSDictionary<NSKeyValueChangeKey,id> *)change {
    
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary<NSKeyValueChangeKey,id> *)change {
        
}

- (void)scrollViewPanGestureStateDidChange:(NSDictionary<NSKeyValueChangeKey,id> *)change {
    
}

- (void)setState:(JLRefreshState)state {
    _state = state;
}

- (void)endRefresh {
    
    self.state = JLRefreshStateIdle;
}

@end
