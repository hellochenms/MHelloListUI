//
//  RefreshLoadMoreViewController.m
//  MHelloListUI
//
//  Created by Chen,Meisong on 2017/8/16.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import "RefreshLoadMoreViewController.h"
#import "GroupKVORefreshView.h"
#import "GroupKVOAutoLoadMoreView.h"
#import "M7TempDataGenerator.h"

static NSTimeInterval const kRefreshLoadMoreTime = 5;

@interface RefreshLoadMoreViewController (Table)<UITableViewDataSource, UITableViewDelegate>
- (void)initDatas;
@end

@interface RefreshLoadMoreViewController ()
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *datas;
@property (nonatomic) GroupKVORefreshView *refreshView;
@property (nonatomic) GroupKVOAutoLoadMoreView *loadMoreView;
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic) BOOL isLoadingMore;
@end

@implementation RefreshLoadMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initDatas];
    [self addMySubviews];
}

#pragma mark - Init
- (void)addMySubviews {
    [self.tableView addSubview:self.refreshView];
    [self.tableView addSubview:self.loadMoreView];
    [self.view addSubview:self.tableView];
}

#pragma mark - Life Cycle
- (void)viewWillLayoutSubviews {
    self.tableView.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 64);
}

#pragma mark - Event
- (void)onTapRefresh {
    [self refreshData];
    [self.refreshView beginRefresh];
}

#pragma mark - Load data
- (void)refreshData {
    self.isRefreshing = YES;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kRefreshLoadMoreTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.datas removeAllObjects];
        [self.datas addObjectsFromArray:[M7TempDataGenerator sameRandomNumberTextArrayForCount:20]];
        [weakSelf.tableView reloadData];
        [weakSelf.refreshView endRefresh];
        weakSelf.isRefreshing = NO;
    });
}

#pragma mark - Load data
- (void)loadMoreData {
    self.isLoadingMore = YES;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kRefreshLoadMoreTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.datas addObjectsFromArray:[M7TempDataGenerator sameRandomNumberTextArrayForCount:5]];
        [weakSelf.tableView reloadData];
        [weakSelf.loadMoreView endLoadMore];
        weakSelf.isLoadingMore = NO;
    });
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    
    return _tableView;
}

- (GroupKVORefreshView *)refreshView {
    if (!_refreshView) {
        _refreshView = [GroupKVORefreshView refreshView];
        __weak typeof(self) weakSelf = self;
        _refreshView.didTriggerRefreshBlock = ^{
            [weakSelf refreshData];
        };
        _refreshView.canRefresh = ^BOOL{
            return (!weakSelf.isRefreshing && !weakSelf.isLoadingMore);
        };
    }
    
    return _refreshView;
}

- (GroupKVOAutoLoadMoreView *)loadMoreView {
    if (!_loadMoreView) {
        _loadMoreView = [GroupKVOAutoLoadMoreView loadMoreView];
        __weak typeof(self) weakSelf = self;
        _loadMoreView.didTriggerLoadMoreBlock = ^{
            [weakSelf loadMoreData];
        };
        _loadMoreView.canLoadMore = ^BOOL{
            return (!weakSelf.isRefreshing && !weakSelf.isLoadingMore);
        };
    }
    
    return _loadMoreView;
}

@end

#pragma mark -
#pragma mark - (Table)
@implementation RefreshLoadMoreViewController (Table)
#pragma mark - Init
- (void)initDatas {
    self.datas = [NSMutableArray array];
    [self.datas addObjectsFromArray:[M7TempDataGenerator sameRandomNumberTextArrayForCount:20]];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.datas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSString *data = self.datas[indexPath.row];
    cell.textLabel.text = data;
    
    return cell;
}

@end
