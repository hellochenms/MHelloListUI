//
//  TestTableViewController.m
//  MHelloListUI
//
//  Created by Chen,Meisong on 2017/8/9.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import "TestTableViewController.h"
#import "ExtraView.h"
#import "M7TempDataGenerator.h"

static NSString * const kKVOKeyContentSize = @"contentSize";
static double const kHeight = 60;


@interface TestTableViewController (Table)<UITableViewDataSource, UITableViewDelegate>
- (void)initDatas;
@end

@interface TestTableViewController ()
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *datas;
@property (nonatomic) ExtraView *bottomInsetView;
@end

@implementation TestTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initDatas];
    [self addMySubviews];
    
    [self addKVO];
}

#pragma mark - Init
- (void)addMySubviews {
    [self.view addSubview:self.tableView];
}

#pragma mark - Life Cycle
- (void)viewWillLayoutSubviews {
    self.tableView.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 64);
}

#pragma mark - KVO
- (void)addKVO {
    [self.tableView addObserver:self forKeyPath:kKVOKeyContentSize options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
}

- (void)removeKVO {
    [self.tableView removeObserver:self forKeyPath:kKVOKeyContentSize];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (![keyPath isEqualToString:kKVOKeyContentSize]) {
        return;
    }
    
    CGRect frame = self.bottomInsetView.frame;
    frame.origin.y = self.tableView.contentSize.height + kHeight;
    self.bottomInsetView.frame = frame;
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor brownColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        double width = CGRectGetWidth([UIScreen mainScreen].bounds);
        
        ExtraView *topInsetView = [[ExtraView alloc] initWithFrame:CGRectMake(0, -kHeight * 2, width, kHeight)];
        topInsetView.backgroundColor = [UIColor redColor];
        topInsetView.onTapBlock = ^{
            NSLog(@"点击topInsetView");
        };
        [_tableView addSubview:topInsetView];
        UIEdgeInsets insets = _tableView.contentInset;
        insets.top = kHeight * 2;
        _tableView.contentInset = insets;
        
        ExtraView *headerView = [[ExtraView alloc] initWithFrame:CGRectMake(0, 0, width, kHeight)];
        headerView.backgroundColor = [UIColor greenColor];
        headerView.onTapBlock = ^{
            NSLog(@"点击headerView");
        };
        _tableView.tableHeaderView = headerView;
        
        ExtraView *footerView = [[ExtraView alloc] initWithFrame:CGRectMake(0, 0, width, kHeight)];
        footerView.backgroundColor = [UIColor blueColor];
        footerView.onTapBlock = ^{
            NSLog(@"点击footerView");
        };
        _tableView.tableFooterView = footerView;
        
        self.bottomInsetView.backgroundColor = [UIColor orangeColor];
        self.bottomInsetView.frame = CGRectMake(0, 0, width, kHeight);
        self.bottomInsetView.onTapBlock = ^{
            NSLog(@"点击bottomInsetView");
        };
        [_tableView addSubview:self.bottomInsetView];
        insets = _tableView.contentInset;
        insets.bottom = kHeight * 2;
        _tableView.contentInset = insets;
        
    }
    
    return _tableView;
}

- (ExtraView *)bottomInsetView {
    if(!_bottomInsetView){
        _bottomInsetView = [ExtraView new];
    }
    
    return _bottomInsetView;
}

#pragma mark - Life Cycle
- (void)dealloc {
    [self removeKVO];
}

@end

#pragma mark -
#pragma mark - (Table)
@implementation TestTableViewController (Table)
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
