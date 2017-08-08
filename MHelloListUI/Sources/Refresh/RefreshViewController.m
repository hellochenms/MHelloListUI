//
//  RefreshViewController.m
//  MHelloListUI
//
//  Created by chenms on 17/8/5.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import "RefreshViewController.h"
#import "M7TempDataGenerator.h"
#import "RefreshView.h"

@interface RefreshViewController (Table)<UITableViewDataSource, UITableViewDelegate>
- (void)initDatas;
@end

@interface RefreshViewController ()
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *datas;
@property (nonatomic) RefreshView *refreshView;
@property (nonatomic) UIActivityIndicatorView *loadingIndicator;
@end

@implementation RefreshViewController

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
    
    [self.view addSubview:self.loadingIndicator];
}

#pragma mark - Life Cycle
- (void)viewWillLayoutSubviews {
    self.tableView.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 64);
    self.loadingIndicator.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2, CGRectGetHeight(self.view.bounds) / 2);
}

#pragma mark - Load data
- (void)refreshData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingIndicator startAnimating];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.loadingIndicator stopAnimating];
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

- (RefreshView *)refreshView {
    if (!_refreshView) {
        _refreshView = [RefreshView refreshView];
        __weak typeof(self) weakSelf = self;
        _refreshView.didTriggerRefreshBlock = ^{
            [weakSelf refreshData];
        };
    }
    
    return _refreshView;
}

- (UIActivityIndicatorView *)loadingIndicator {
    if (!_loadingIndicator) {
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];    }
    
    return _loadingIndicator;
}

@end

#pragma mark -
#pragma mark - (Table)
@implementation RefreshViewController (Table)
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
@implementation RefreshViewController (Scroll)
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.refreshView scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.refreshView scrollViewDidEndDragging:scrollView];
}

@end
