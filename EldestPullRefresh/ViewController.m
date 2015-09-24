//
//  ViewController.m
//  EldestPullRefresh
//
//  Created by WilliamZhang on 15/9/24.
//  Copyright © 2015年 WilliamZhang. All rights reserved.
//

#import "ViewController.h"
#import "EldestPullRefresh.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, EldestPullDelegate>

@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) EldestPullRefresh *headerView;
@property (nonatomic ,getter=isLoading) BOOL loading;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    
    
    [self.headerView refreshLastUpdatedDate];
}

#pragma mark -
#pragma mark Private Method
- (void)reloadTableViewData {
    self.loading = YES;
}

- (void)doneLoadingTableViewData {
    self.loading = NO;
    [self.headerView eldestRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark -
#pragma mark EldestPullRefresh Delegate
- (NSDate *)eldestRefreshTableHeaderDataSourceLastUpdated:(EldestPullRefresh *)headerView {
    return [NSDate date];
}

- (BOOL)eldestRefreshTableHeaderDataSourceIsLoading:(EldestPullRefresh *)headerView {
    return self.isLoading;
}

- (void)eldestRefreshTableHeaderDidTriggerRefresh:(EldestPullRefresh *)headerView {
    [self reloadTableViewData];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3];
}

#pragma mark - 
#pragma mark UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Secion: %ld",section];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.headerView eldestRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%@",NSStringFromCGPoint(scrollView.contentOffset));
    [self.headerView eldestRefreshScrollViewDidScroll:scrollView];
}

#pragma mark -
#pragma mark Initializer
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [_tableView addSubview:self.headerView];
    }
    return _tableView;
}

- (EldestPullRefresh *)headerView {
    if (!_headerView) {
        _headerView = [[EldestPullRefresh alloc] initWithFrame:CGRectMake(0, 0 - CGRectGetHeight(self.tableView.bounds), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.tableView.bounds))];
        _headerView.delegate = self;
    }
    return _headerView;
}

@end
