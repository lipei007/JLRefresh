//
//  JLRefreshHeader.h
//  JLRefreshDemo
//
//  Created by Jack on 2017/3/6.
//  Copyright © 2017年 mini1. All rights reserved.
//

#import "JLRefreshBasis.h"

@interface JLRefreshHeader : JLRefreshBasis


- (void)setRefreshTitle:(NSString *)title forState:(JLRefreshState)state;

- (NSString *)refreshTitleForState:(JLRefreshState)state;

@end
