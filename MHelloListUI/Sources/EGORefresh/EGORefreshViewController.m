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
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.refreshView];
}

#pragma mark - Life Cycle
- (void)viewWillLayoutSubviews {
    self.tableView.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 64);
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
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.datas removeAllObjects];
                [weakSelf.datas addObjectsFromArray:[M7TempDataGenerator sameRandomNumberTextArrayForCount:20]];
                [weakSelf.tableView reloadData];
                [weakSelf.refreshView endRefresh:weakSelf.tableView];
            });
        };
    }
    
    return _refreshView;
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

