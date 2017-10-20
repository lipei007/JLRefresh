//
//  JLRefreshFooter.h
//  JLRefreshDemo
//
//  Created by Jack on 2017/3/7.
//  Copyright © 2017年 mini1. All rights reserved.
//

#import "JLRefreshBasis.h"

@interface JLRefreshFooter : JLRefreshBasis

@property (nonatomic,assign) BOOL showDefaultTips;

- (void)noMoreData;

@end
