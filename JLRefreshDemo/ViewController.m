//
//  ViewController.m
//  JLRefreshDemo
//
//  Created by Jack on 2017/3/3.
//  Copyright © 2017年 mini1. All rights reserved.
//

#import "ViewController.h"
#import "JLRefreshHeader.h"
#import "JLRefreshFooter.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,JLRefreshDelegate>

@property (nonatomic,strong) NSMutableArray *dataSource;
@property (strong, nonatomic) IBOutlet UITableView *table;

@property (nonatomic,strong) UIView *refresh;

@end

@implementation ViewController{
    int count;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.table.tableFooterView = [UIView new];
    self->count = 10;
    
    self.table.jl_header = [[JLRefreshHeader alloc] init];
    self.table.jl_header.refreshDelegate = self;
    
    self.table.jl_footer = [[JLRefreshFooter alloc] init];
    self.table.jl_footer.refreshDelegate = self;
    
//    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.wgt"];
//    [userDefaults setObject:@"WS10" forKey:@"China"];
//
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self->count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return CGRectGetHeight(tableView.bounds) / 10;
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 30)];
    header.backgroundColor = [UIColor colorWithRed:0.4 green:0.2 blue:0.7 alpha:0.7];
    return header;
}

#pragma mark - RefreshDelegate

- (void)jl_pullRefresh:(JLRefreshBasis *)refresh state:(JLRefreshState)state percentage:(float)percentage {
    
    if ([refresh isEqual:self.table.jl_header]) {
        if (percentage <= 1) {
             self.table.jl_header.backgroundColor = [UIColor colorWithRed:0.4 * percentage green:0.4 * percentage blue:0.6 * percentage alpha:percentage];
        }
    }
    
    if (refresh == self.table.jl_footer) {
        if (percentage <= 1) {
            self.table.jl_footer.backgroundColor = [UIColor colorWithRed:0.1 * percentage green:0.4 * percentage blue:0.8 * percentage alpha:percentage];
        }
    }

}

- (void)jl_endRefresh:(JLRefreshBasis *)refresh {
    // state == idle
    {
        // refresh UI
        [self.table reloadData];
        if (refresh == self.table.jl_footer && refresh.state == JLRefreshStateNoMore) {
            refresh.backgroundColor = [UIColor redColor];
        }
    }
}

- (void)jl_beginRefresh:(JLRefreshBasis *)refresh {
    // state == refreshing
    // load data
    if (self->count < 50) {
        self->count += 5;
    }
    
    {
        // finish loading data
        if (refresh == self.table.jl_header) [self.table.jl_header performSelector:@selector(endRefresh) withObject:refresh afterDelay:5.0f];
        if (refresh == self.table.jl_footer && self->count < 50) [self.table.jl_footer performSelector:@selector(endRefresh) withObject:refresh afterDelay:5.0f];
        if (refresh == self.table.jl_footer && self->count >= 50) [self.table.jl_footer performSelector:@selector(noMoreData) withObject:refresh afterDelay:5.0f];
    }
}


@end
