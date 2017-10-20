//
//  TodayViewController.m
//  Widget
//
//  Created by Jack on 2017/4/7.
//  Copyright © 2017年 mini1. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>
@property (strong, nonatomic) IBOutlet UILabel *myl;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.preferredContentSize = CGSizeMake(0, 300);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.wgt"];
    self.myl.text = [userDefaults valueForKey:@"China"];

}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

/**
 activeDisplayMode有以下两种
 NCWidgetDisplayModeCompact, // 收起模式
 NCWidgetDisplayModeExpanded, // 展开模式
 */
//- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
//    if(activeDisplayMode == NCWidgetDisplayModeCompact) {
//        // 尺寸只设置高度即可，因为宽度是固定的，设置了也不会有效果
//        self.preferredContentSize = CGSizeMake(0, 110);
//    } else {
//        self.preferredContentSize = CGSizeMake(0, 310);
//    }
//}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    
    return UIEdgeInsetsZero;
}

- (IBAction)flight:(UIButton *)sender {
    
    
    NSURL *url = [NSURL URLWithString:@"RfreshWidget://Action"];
    [self.extensionContext openURL:url completionHandler:^(BOOL success) {
        
    }];
    
}
- (IBAction)rock:(id)sender {
    
}
- (IBAction)car:(id)sender {
    
}

@end
