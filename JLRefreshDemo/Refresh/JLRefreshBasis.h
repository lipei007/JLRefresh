//
//  JLRefresh.h
//  JLRefreshDemo
//
//  Created by Jack on 2017/3/3.
//  Copyright © 2017年 mini1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+JLRefresh.h"
#import "UIView+JLExtension.h"

typedef enum {
    /**空闲状态*/
    JLRefreshStateIdle = 1 << 0,
    /**下拉状态*/
    JLRefreshStatePulling = 1 << 1,
    /**即将刷新,还未松开*/
    JLRefreshStateWillRefresh = 1 << 2,
    /**刷新状态，松开*/
    JLRefreshStateRefreshing = 1 << 3,
    /**没有更多数据*/
    JLRefreshStateNoMore = 1 << 4
    
} JLRefreshState;

UIKIT_EXTERN NSTimeInterval const JLRefreshDuration;
UIKIT_EXTERN CGFloat const JLRefreshHeight;
UIKIT_EXTERN NSString *const JLRefreshKeyPathContentOffset;
UIKIT_EXTERN NSString *const JLRefreshKeyPathContentSize;
UIKIT_EXTERN NSString *const JLRefreshKeyPathContentInset;
UIKIT_EXTERN NSString *const JLRefreshKeyPathState;

@class JLRefreshBasis;
@protocol JLRefreshDelegate <NSObject>

- (void)jl_pullRefresh:(JLRefreshBasis *)refresh state:(JLRefreshState)state percentage:(float)percentage;//percentage's range [0,max)

- (void)jl_beginRefresh:(JLRefreshBasis *)refresh;

- (void)jl_endRefresh:(JLRefreshBasis *)refresh;

@end

@interface JLRefreshBasis : UIView

@property (nonatomic,assign) JLRefreshState state;
@property (nonatomic,assign) float pullPercentage;
@property (nonatomic,weak,readonly) UIScrollView *scrollView;
@property (nonatomic,assign,readonly) CGFloat scrollViewOriginInsetTop; ///<header只管Top
@property (nonatomic,assign,readonly) CGFloat scrollViewOriginInsetBottom; ///<footer只管Bottom
@property (nonatomic,strong,readonly) UIPanGestureRecognizer *pan;
@property (nonatomic,weak) id<JLRefreshDelegate> refreshDelegate;
@property (nonatomic,assign) float pullPercentate;

- (void)endRefresh;

- (void)prepareInterface;

// 需要子类实现
- (void)scrollViewContentSizeDidChange:(NSDictionary<NSKeyValueChangeKey,id> *)change;
- (void)scrollViewContentOffsetDidChange:(NSDictionary<NSKeyValueChangeKey,id> *)change;
- (void)scrollViewPanGestureStateDidChange:(NSDictionary<NSKeyValueChangeKey,id> *)change;

@end
