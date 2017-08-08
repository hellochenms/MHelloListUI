//
//  EGORefreshViewController.m
//  MHelloListUI
//
//  Created by chenms on 17/8/5.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import "EGORefreshViewController.h"
#import "EGORefreshView.h"
#import "M7TempDataGenerator.h"

@interface EGORefreshViewController (Table)<UITableViewDataSource, UITableViewDelegate>
- (void)initDatas;
@end

@interface EGORefreshViewController (Scroll)<UIScrollViewDelegate>
@end

@interface EGORefreshViewController ()
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *datas;
@property (nonatomic) EGORefreshView *refreshView;
@property (nonatomic) UIButton *refreshButton;
@end

@implementation EGORefreshViewController

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
    [self.refreshView beginRefresh:self.tableView];
}

#pragma mark - Load data
- (void)refreshData {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.datas removeAllObjects];
        [self.datas addObjectsFromArray:[M7TempDataGenerator sameRandomNumberTextArrayForCount:20]];
        [self.tableView reloadData];
        [self.refreshView endRefresh:self.tableView];
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

- (EGORefreshView *)refreshView {
    if (!_refreshView) {
        _refreshView = [EGORefreshView refreshView];
        __weak typeof(self) weakSelf = self;
        _refreshView.didTriggerRefreshBlock = ^{
            [weakSelf refreshData];
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
@implementation EGORefreshViewController (Table)
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

#pragma mark -
#pragma mark - (Scroll)
@implementation EGORefreshViewController (Scroll)
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.refreshView scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.refreshView scrollViewDidEndDragging:scrollView];
}

@end

