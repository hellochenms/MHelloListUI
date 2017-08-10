//
//  MultEndStatusRefreshView.m
//  MHelloListUI
//
//  Created by Chen,Meisong on 2017/8/10.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import "MultEndStatusRefreshView.h"

static double const kHeight = 60;
static double const kAnimationDuration = .2;

static NSString * const kKeyPathContentOffset = @"contentOffset";
static NSString * const kKeyPathPanState = @"state";

typedef NS_ENUM(NSUInteger, MultEndStatusRefreshViewStatus) {
    MultEndStatusRefreshViewStatusNormal = 0,
    MultEndStatusRefreshViewStatusPulling,
    MultEndStatusRefreshViewStatusLoading,
    MultEndStatusRefreshViewStatusShowLabel,
    MultEndStatusRefreshViewStatusShowButton,
};

@interface MultEndStatusRefreshView ()
@property (nonatomic) MultEndStatusRefreshViewStatus status;
@property (nonatomic) UILabel *label;
@property (nonatomic) UIButton *button;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic) BOOL originalAlwaysBounceVertical;
@property (nonatomic) UIPanGestureRecognizer *pan; // 无法确定系统释放时机，可能导致KVO问题，故用strong变量维护
@property (nonatomic, copy) NSString *text;
@end

@implementation MultEndStatusRefreshView

+ (instancetype)refreshView {
    return [self new];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, -kHeight, CGRectGetWidth([UIScreen mainScreen].bounds), kHeight)];
    if (self) {
        self.backgroundColor = [UIColor brownColor];
        self.status = MultEndStatusRefreshViewStatusNormal;
        
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
    }
}

#pragma mark - KVO
- (void)addKVO {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew;
    [self.scrollView addObserver:self forKeyPath:kKeyPathContentOffset options:options context:nil];
    self.pan = self.scrollView.panGestureRecognizer;
    [self.pan addObserver:self forKeyPath:kKeyPathPanState options:options context:nil];
}

- (void)removeKVO {
    // 不亲自写一下，还真不知道为什么用self.superview，为什么手动维护pan
    [self.superview removeObserver:self forKeyPath:kKeyPathContentOffset];
    [self.pan removeObserver:self forKeyPath:kKeyPathPanState];
    self.pan = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kKeyPathContentOffset]) {
        [self scrollViewDidScroll:self.scrollView];
    } else if ([keyPath isEqualToString:kKeyPathPanState]) {
        if (self.scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            [self scrollViewDidEndDragging:self.scrollView];
        }
    }
}

#pragma mark - ScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.status == MultEndStatusRefreshViewStatusLoading
        || self.status == MultEndStatusRefreshViewStatusShowLabel
        || self.status == MultEndStatusRefreshViewStatusShowButton) {
        UIEdgeInsets inset = scrollView.contentInset;
        inset.top = fmin(fmax(scrollView.contentOffset.y * -1, 0), kHeight);
        scrollView.contentInset = inset;
        return;
    }
    
    if (!scrollView.isDragging) {
        return;
    }
    
    if (scrollView.contentOffset.y < -kHeight) {
        if (self.status == MultEndStatusRefreshViewStatusNormal) {
            self.status = MultEndStatusRefreshViewStatusPulling;
        }
    } else {
        if (self.status == MultEndStatusRefreshViewStatusPulling) {
            self.status = MultEndStatusRefreshViewStatusNormal;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView {
    if (self.status == MultEndStatusRefreshViewStatusLoading
        || self.status == MultEndStatusRefreshViewStatusShowLabel
        || self.status == MultEndStatusRefreshViewStatusShowButton) {
        return;
    }
    
    if (scrollView.contentOffset.y < -kHeight) {
        if (self.didTriggerRefreshBlock) {
            self.status = MultEndStatusRefreshViewStatusLoading;
            UIEdgeInsets inset = scrollView.contentInset;
            inset.top = kHeight;
            scrollView.contentInset = inset;
            self.didTriggerRefreshBlock();
        }
    }
}

#pragma mark - Public
- (void)endRefresh{
    self.status = MultEndStatusRefreshViewStatusNormal;
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.top = 0;
        self.scrollView.contentInset = inset;
    }];
}

- (void)endRefreshWithLabel:(NSString *)text {
    self.text = text;
    self.status = MultEndStatusRefreshViewStatusShowLabel;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.status = MultEndStatusRefreshViewStatusNormal;
        [UIView animateWithDuration:kAnimationDuration animations:^{
            UIEdgeInsets inset = self.scrollView.contentInset;
            inset.top = 0;
            self.scrollView.contentInset = inset;
        }];
    });
}

- (void)endRefreshWithButton {
    self.status = MultEndStatusRefreshViewStatusShowButton;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.status = MultEndStatusRefreshViewStatusNormal;
        [UIView animateWithDuration:kAnimationDuration animations:^{
            UIEdgeInsets inset = self.scrollView.contentInset;
            inset.top = 0;
            self.scrollView.contentInset = inset;
        }];
    });
}

- (void)beginRefresh {
    if (self.status == MultEndStatusRefreshViewStatusLoading) {
        return;
    }
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.scrollView.contentOffset = CGPointMake(0, -kHeight);
        
        self.status = MultEndStatusRefreshViewStatusLoading;
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.top = kHeight;
        self.scrollView.contentInset = inset;
    }];
}

#pragma mark - Status
- (void)setStatus:(MultEndStatusRefreshViewStatus)status {
    _status = status;
    
    switch (status) {
        case MultEndStatusRefreshViewStatusNormal:
            self.label.hidden = NO;
            self.button.hidden = YES;
            self.label.text = @"下拉即可刷新";
            break;
        case MultEndStatusRefreshViewStatusPulling:
            self.label.hidden = NO;
            self.button.hidden = YES;
            self.label.text = @"松开即可刷新";
            break;
        case MultEndStatusRefreshViewStatusLoading:
            self.label.hidden = NO;
            self.button.hidden = YES;
            self.label.text = @"刷新中";
            break;
        case MultEndStatusRefreshViewStatusShowLabel:
            self.label.hidden = NO;
            self.button.hidden = YES;
            self.label.text = self.text;
            break;
        case MultEndStatusRefreshViewStatusShowButton:
            self.label.hidden = YES;
            self.button.hidden = NO;
            break;
        default:
            break;
    }
}

#pragma mark - Event
- (void)onTapNoMoreButton {
    if (self.onTapButtonBlock) {
        self.onTapButtonBlock();
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
