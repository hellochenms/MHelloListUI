
//
//  MultEndStatusLoadMoreView.m
//  MHelloListUI
//
//  Created by Chen,Meisong on 2017/8/10.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import "MultEndStatusLoadMoreView.h"

static double const kHeight = 60;
static double const kAnimationDuration = .2;

static NSString * const kKeyPathContentOffset = @"contentOffset";
static NSString * const kKeyPathContentSize = @"contentSize";

typedef NS_ENUM(NSUInteger, MultEndStatusLoadMoreViewStatus) {
    MultEndStatusLoadMoreViewStatusNormal = 0,
    MultEndStatusLoadMoreViewStatusLoading,
    MultEndStatusLoadMoreViewStatusNoMore,
    MultEndStatusLoadMoreViewStatusNoMoreCanTap,
};

@interface MultEndStatusLoadMoreView ()
@property (nonatomic) MultEndStatusLoadMoreViewStatus status;
@property (nonatomic) UILabel *label;
@property (nonatomic) UIButton *button;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic) BOOL originalAlwaysBounceVertical;
@end


@implementation MultEndStatusLoadMoreView

+ (instancetype)loadMoreView {
    return [self new];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), kHeight)];
    if (self) {
        self.backgroundColor = [UIColor brownColor];
        self.status = MultEndStatusLoadMoreViewStatusNormal;
        
        [self addSubview:self.label];
        self.button.hidden = YES;
        [self addSubview:self.button];
        
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.label.frame = self.bounds;
    self.button.frame = self.bounds;
}

#pragma mark - Life Cycle
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview && ![newSuperview isKindOfClass:[UIScrollView class]]) {
        return;
    }
    
    self.scrollView.alwaysBounceVertical = self.originalAlwaysBounceVertical;
    [self removeKVO];
    
    
    if (newSuperview) {
        self.scrollView = (UIScrollView *)newSuperview;
        self.originalAlwaysBounceVertical = self.scrollView.alwaysBounceVertical;
        self.scrollView.alwaysBounceVertical = YES;
        [self addKVO];
        
        [self scrollViewDidChangeContentSize:self.scrollView];
    }
}

#pragma mark - KVO
- (void)addKVO {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew;
    [self.scrollView addObserver:self forKeyPath:kKeyPathContentOffset options:options context:nil];
    [self.scrollView addObserver:self forKeyPath:kKeyPathContentSize options:options context:nil];
}

- (void)removeKVO {
    [self.superview removeObserver:self forKeyPath:kKeyPathContentOffset];
    [self.superview removeObserver:self forKeyPath:kKeyPathContentSize];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kKeyPathContentOffset]) {
        [self scrollViewDidScroll:self.scrollView];
    } else if ([keyPath isEqualToString:kKeyPathContentSize]) {
        [self scrollViewDidChangeContentSize:self.scrollView];
    }
}

#pragma mark - ScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.hidden) {
        return;
    }
    if (self.status == MultEndStatusLoadMoreViewStatusLoading) {
        return;
    }
    if (!scrollView.isDragging) {
        return;
    }
    
    if (CGRectGetHeight(self.scrollView.bounds) + scrollView.contentOffset.y - self.scrollView.contentSize.height > 0) {
        if (self.status == MultEndStatusLoadMoreViewStatusNormal) {
            if (self.didTriggerLoadMoreBlock) {
                self.status = MultEndStatusLoadMoreViewStatusLoading;
                UIEdgeInsets inset = scrollView.contentInset;
                inset.bottom = kHeight;
                scrollView.contentInset = inset;
                self.didTriggerLoadMoreBlock();
            }
        }
    }
}

- (void)scrollViewDidChangeContentSize:(UIScrollView *)scrollView {
    CGRect frame = self.frame;
    frame.origin.y = self.scrollView.contentSize.height;
    self.frame = frame;
    
    if (scrollView.contentSize.height >= scrollView.bounds.size.height) {
        self.hidden = NO;
    } else {
        self.hidden = YES;
    }
}

#pragma mark - Public
- (void)endLoadMore {
    self.status = MultEndStatusLoadMoreViewStatusNormal;
    UIEdgeInsets inset = self.scrollView.contentInset;
    inset.bottom = 0;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.scrollView.contentInset = inset;
    }];
}

- (void)endLoadMoreWithNoMoreLabel {
    self.status = MultEndStatusLoadMoreViewStatusNoMore;
}

- (void)endLoadMoreWithNoMoreButton {
    self.status = MultEndStatusLoadMoreViewStatusNoMoreCanTap;
}

- (void)reset {
    self.status = MultEndStatusLoadMoreViewStatusNormal;
    UIEdgeInsets inset = self.scrollView.contentInset;
    inset.bottom = 0;
    self.scrollView.contentInset = inset;
}

#pragma mark - Status
- (void)setStatus:(MultEndStatusLoadMoreViewStatus)status {
    _status = status;
    
    switch (status) {
        case MultEndStatusLoadMoreViewStatusNormal:
            self.label.text = @"上拉即可加载";
            self.label.hidden = NO;
            self.button.hidden = YES;
            break;
        case MultEndStatusLoadMoreViewStatusLoading:
            self.label.text = @"加载中";
            self.label.hidden = NO;
            self.button.hidden = YES;
            break;
        case MultEndStatusLoadMoreViewStatusNoMore:
            self.label.text = @"没有更多了";
            self.label.hidden = NO;
            self.button.hidden = YES;
            break;
        case MultEndStatusLoadMoreViewStatusNoMoreCanTap:
            self.label.hidden = YES;
            self.button.hidden = NO;
            break;
        default:
            break;
    }
}

#pragma mark - Event
- (void)onTapNoMoreButton {
    if (self.onTapNoMoreButtonBlock) {
        self.onTapNoMoreButtonBlock();
    }
}

#pragma mark - Getter
- (UILabel *)label {
    if (!_label) {
        _label = [UILabel new];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor whiteColor];
    }
    
    return _label;
}

- (UIButton *)button {
    if(!_button){
        _button = [UIButton buttonWithType:UIButtonTypeSystem];
        [_button setTitle:@"点击触发xxx操作" forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(onTapNoMoreButton) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _button;
}

@end
