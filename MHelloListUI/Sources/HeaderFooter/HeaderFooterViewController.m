//
//  HeaderFooterViewController.m
//  MHelloListUI
//
//  Created by Chen,Meisong on 2017/8/16.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import "HeaderFooterViewController.h"
#import "HeaderKVORefreshView.h"
#import "FooterKVOAutoLoadMoreView.h"
#import "M7TempDataGenerator.h"
#import "Header.h"
#import "Footer.h"

static NSTimeInterval const kRefreshLoadMoreTime = 2;

@interface HeaderFooterViewController (Table)<UITableViewDataSource, UITableViewDelegate>
- (void)initDatas;
@end

@interface HeaderFooterViewController ()
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *datas;
@property (nonatomic) HeaderKVORefreshView *refreshView;
@property (nonatomic) Header *header;
@property (nonatomic) FooterKVOAutoLoadMoreView *loadMoreView;
@property (nonatomic) Footer *footer;
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic) BOOL isLoadingMore;
@end

@implementation HeaderFooterViewController

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
        BOOL hasData = (arc4random() % 2 == 0);
        if (hasData) {
            [self.datas removeAllObjects];
            [self.datas addObjectsFromArray:[M7TempDataGenerator sameRandomNumberTextArrayForCount:20]];
            [weakSelf.tableView reloadData];
        } else {
            self.refreshView.hidden = YES;
            self.tableView.tableHeaderView = self.header;
        }
        
        [weakSelf.refreshView endRefresh];
        weakSelf.isRefreshing = NO;
    });
}

#pragma mark - Load data
- (void)loadMoreData {
    self.isLoadingMore = YES;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kRefreshLoadMoreTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL hasData = (arc4random() % 2 == 0);
        if (hasData) {
            [weakSelf.datas addObjectsFromArray:[M7TempDataGenerator sameRandomNumberTextArrayForCount:5]];
            [weakSelf.tableView reloadData];
        } else {
            self.loadMoreView.hidden = YES;
            self.tableView.tableFooterView = self.footer;
            
            [UIView animateWithDuration:0.2 animations:^{
                UIEdgeInsets inset = self.tableView.contentInset;
                inset.bottom = 0;
                self.tableView.contentInset = inset;
                self.tableView.contentOffset = CGPointMake(0, self.tableView.contentSize.height - CGRectGetHeight(self.tableView.bounds));
            }];
            
//            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - CGRectGetHeight(self.tableView.bounds)) animated:YES];
        }
        
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

- (HeaderKVORefreshView *)refreshView {
    if (!_refreshView) {
        _refreshView = [HeaderKVORefreshView refreshView];
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

- (Header *)header {
    if(!_header){
        _header = [Header new];
        _header.frame = CGRectMake(0, 0, 0, 50);
        _header.onTapBlock = ^{
            NSLog(@"点击header  %s", __func__);
        };
    }
    
    return _header;
}

- (FooterKVOAutoLoadMoreView *)loadMoreView {
    if (!_loadMoreView) {
        _loadMoreView = [FooterKVOAutoLoadMoreView loadMoreView];
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

- (Footer *)footer {
    if(!_footer){
        _footer = [Footer new];
        _footer.frame = CGRectMake(0, 0, 0, 50);
        _footer.onTapBlock = ^{
            NSLog(@"点击footer  %s", __func__);
        };
    }
    
    return _footer;
}

@end

#pragma mark -
#pragma mark - (Table)
@implementation HeaderFooterViewController (Table)
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
