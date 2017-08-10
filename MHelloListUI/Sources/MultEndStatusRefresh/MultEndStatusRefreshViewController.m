//
//  MultEndStatusRefreshViewController.m
//  MHelloListUI
//
//  Created by Chen,Meisong on 2017/8/10.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import "MultEndStatusRefreshViewController.h"
#import "MultEndStatusRefreshView.h"
#import "M7TempDataGenerator.h"

@interface MultEndStatusRefreshViewController (Table)<UITableViewDataSource, UITableViewDelegate>
- (void)initDatas;
@end

@interface MultEndStatusRefreshViewController ()
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *datas;
@property (nonatomic) MultEndStatusRefreshView *refreshView;
@property (nonatomic) UIButton *refreshButton;
@end

@implementation MultEndStatusRefreshViewController

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
    [self.refreshView beginRefresh];
}

#pragma mark - Load data
- (void)refreshData {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.datas removeAllObjects];
        [weakSelf.datas addObjectsFromArray:[M7TempDataGenerator sameRandomNumberTextArrayForCount:20]];
        [weakSelf.tableView reloadData];
        
        NSInteger option = arc4random() % 3;
        if (option == 0) {
            [self.refreshView endRefresh];
        } else if (option == 1) {
            [self.refreshView endRefreshWithLabel:@"刷新了20条"];
        } else {
            [self.refreshView endRefreshWithButton];
        }
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

- (MultEndStatusRefreshView *)refreshView {
    if (!_refreshView) {
        _refreshView = [MultEndStatusRefreshView refreshView];
        __weak typeof(self) weakSelf = self;
        _refreshView.didTriggerRefreshBlock = ^{
            [weakSelf refreshData];
        };
        _refreshView.onTapButtonBlock = ^{
            NSLog(@"点击触发xxx操作");
        };
    }
    
    return _refreshView;
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
@implementation MultEndStatusRefreshViewController (Table)
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
