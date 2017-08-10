//
//  MultEndStatusLoadMoreViewController.m
//  MHelloListUI
//
//  Created by Chen,Meisong on 2017/8/10.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import "MultEndStatusLoadMoreViewController.h"
#import "MultEndStatusLoadMoreView.h"
#import "M7TempDataGenerator.h"

static NSInteger const kPage = 10;

@interface MultEndStatusLoadMoreViewController (Table)<UITableViewDataSource, UITableViewDelegate>
- (void)initDatas;
@end

@interface MultEndStatusLoadMoreViewController ()
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *datas;
@property (nonatomic) MultEndStatusLoadMoreView *loadMoreView;
@property (nonatomic) UIButton *refreshButton;
@property (nonatomic) UIButton *clearButton;
@end

@implementation MultEndStatusLoadMoreViewController

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
    [self.tableView addSubview:self.loadMoreView];
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.refreshButton];
    [self.view addSubview:self.clearButton];
}

#pragma mark - Life Cycle
- (void)viewWillLayoutSubviews {
    self.tableView.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 64);
    
    self.refreshButton.frame = CGRectMake(CGRectGetWidth(self.view.bounds) - 20 - 80, 64 + 60 + 20, 80, 40);
    self.clearButton.frame = CGRectMake(CGRectGetWidth(self.view.bounds) - 20 - 80, CGRectGetMaxY(self.refreshButton.frame) + 20, 80, 40);
}

#pragma mark - Load data
- (void)loadMoreData {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.datas addObjectsFromArray:[M7TempDataGenerator sameRandomNumberTextArrayForCount:kPage]];
        [self.tableView reloadData];
        
        NSInteger option = arc4random() % 3;
        if (option == 0) {
            [self.loadMoreView endLoadMore];
        } else if (option == 1) {
            [self.loadMoreView endLoadMoreWithNoMoreLabel];
        } else {
            [self.loadMoreView endLoadMoreWithNoMoreButton];
        }
    });
}

#pragma mark - Event
- (void)onTapRefresh {
    [self refreshData];
}

- (void)onTapClear {
    [self.datas removeAllObjects];
    [self.tableView reloadData];
    
    [self.loadMoreView reset];
}

#pragma mark - Load data
- (void)refreshData {
    NSMutableArray *datas = [NSMutableArray array];
    [datas addObjectsFromArray:[M7TempDataGenerator sameRandomNumberTextArrayForCount:kPage]];
    [datas addObjectsFromArray:self.datas];
    self.datas = datas;
    [self.tableView reloadData];
    
    [self.loadMoreView reset];
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

- (MultEndStatusLoadMoreView *)loadMoreView {
    if (!_loadMoreView) {
        _loadMoreView = [MultEndStatusLoadMoreView loadMoreView];
        __weak typeof(self) weakSelf = self;
        _loadMoreView.didTriggerLoadMoreBlock = ^{
            [weakSelf loadMoreData];
        };
        _loadMoreView.onTapNoMoreButtonBlock = ^{
            NSLog(@"点击触发xxx操作");
        };
    }
    
    return _loadMoreView;
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

- (UIButton *)clearButton {
    if (!_clearButton) {
        _clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _clearButton.backgroundColor = [UIColor brownColor];
        [_clearButton setTitle:@"清空" forState:UIControlStateNormal];
        [_clearButton addTarget:self action:@selector(onTapClear) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _clearButton;
}

@end

#pragma mark -
#pragma mark - (Table)
@implementation MultEndStatusLoadMoreViewController (Table)
#pragma mark - Init
- (void)initDatas {
    self.datas = [NSMutableArray array];
    [self.datas addObjectsFromArray:[M7TempDataGenerator sameRandomNumberTextArrayForCount:kPage]];
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
