//
//  UIScrollViewCategoryViewController.m
//  MHelloListUI
//
//  Created by Chen,Meisong on 2017/8/16.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import "UIScrollViewCategoryViewController.h"
#import "KVORefreshView.h"
#import "M7TempDataGenerator.h"
#import "UIScrollView+M4RefreshLoadMore.h"

@interface UIScrollViewCategoryViewController (Table)<UITableViewDataSource, UITableViewDelegate>
- (void)initDatas;
@end

@interface UIScrollViewCategoryViewController ()
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *datas;
@property (nonatomic) UIButton *refreshButton;
@end

@implementation UIScrollViewCategoryViewController

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
    KVORefreshView *refreshView = [KVORefreshView refreshView];
    __weak typeof(self) weakSelf = self;
    refreshView.didTriggerRefreshBlock = ^{
        [weakSelf refreshData];
    };
    self.tableView.m4_refreshView = refreshView;
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.refreshButton];
}

#pragma mark - Life Cycle
- (void)viewWillLayoutSubviews {
    self.tableView.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 64);
    self.refreshButton.frame = CGRectMake(CGRectGetWidth(self.view.bounds) - 20 - 80, 64 + 60 + 20, 80, 40);
}

#pragma mark - Event
- (void)onTapRefresh {
    [self refreshData];
    [self.tableView.m4_refreshView beginRefresh];
}

#pragma mark - Load data
- (void)refreshData {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.datas removeAllObjects];
        [weakSelf.datas addObjectsFromArray:[M7TempDataGenerator sameRandomNumberTextArrayForCount:20]];
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.m4_refreshView endRefresh];
    });
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    
    return _tableView;
}

- (UIButton *)refreshButton {
    if (!_refreshButton) {
        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _refreshButton.backgroundColor = [UIColor brownColor];
        [_refreshButton setTitle:@"刷新" forState:UIControlStateNormal];
        [_refreshButton addTarget:self action:@selector(onTapRefresh) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _refreshButton;
}

@end

#pragma mark -
#pragma mark - (Table)
@implementation UIScrollViewCategoryViewController (Table)
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
