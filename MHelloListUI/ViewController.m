//
//  ViewController.m
//  MHelloListUI
//
//  Created by chenms on 17/8/5.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import "ViewController.h"
#import "EGORefreshViewController.h"
#import "RefreshViewController.h"
#import "KVORefreshViewController.h"
#import "KVOLoadMoreViewController.h"
#import "RefreshViewController.h"
#import "KVOAutoLoadMoreViewController.h"
#import "TestTableViewController.h"
#import "MultEndStatusLoadMoreViewController.h"
#import "MultEndStatusRefreshViewController.h"
#import "ScrollObserverViewController.h"
#import "ShorterThanScreenCanLoadMoreViewController.h"
#import "RefreshLoadMoreViewController.h"
#import "AlwaysBottomLoadMoreViewController.h"
#import "HeaderFooterViewController.h"
#import "UIScrollViewCategoryViewController.h"

@interface ViewController (Table)<UITableViewDataSource, UITableViewDelegate>
- (void)initDatas;
@end

@interface ViewController ()
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray *datas;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self initDatas];
    [self addMySubviews];
}

#pragma mark - Init
- (void)addMySubviews {
    [self.view addSubview:self.tableView];
}

#pragma mark - Life Cycle
- (void)viewWillLayoutSubviews {
    self.tableView.frame = self.view.bounds;
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

@end


#pragma mark -
#pragma mark - (Table)
@implementation ViewController (Table)
#pragma mark - Init
- (void)initDatas {
    self.datas = @[@[@"测试TableView", [TestTableViewController class]],
                   @[@"只负责触发的下拉刷新", [RefreshViewController class]],
                   @[@"EGO时代的下拉刷新", [EGORefreshViewController class]],
                   @[@"EGO风格的KVO下拉刷新", [KVORefreshViewController class]],
                   @[@"EGO风格的KVO上拉加载", [KVOLoadMoreViewController class]],
                   @[@"滑到位置自动加载", [KVOAutoLoadMoreViewController class]],
                   @[@"加载结果有多种状态", [MultEndStatusLoadMoreViewController class]],
                   @[@"刷新有多种状态", [MultEndStatusRefreshViewController class]],
                   @[@"提取出ScrollObserver与contentView", [ScrollObserverViewController class]],
                   @[@"不满一屏也可以上滑加载", [ShorterThanScreenCanLoadMoreViewController class]],
                   @[@"刷新+加载", [RefreshLoadMoreViewController class]],
                   @[@"上滑控件始终在屏幕底部", [AlwaysBottomLoadMoreViewController class]],
                   @[@"HeaderFooter方式的NoMoreData", [HeaderFooterViewController class]],
                   @[@"UIScrollView的扩展-下拉刷新", [UIScrollViewCategoryViewController class]],
                   ];
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
    
    NSArray *data = self.datas[indexPath.row];
    cell.textLabel.text = data[0];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *data = self.datas[indexPath.row];
    
    UIViewController *controller = [data[1] new];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
