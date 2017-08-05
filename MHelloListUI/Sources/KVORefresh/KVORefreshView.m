//
//  KVORefreshView.m
//  MHelloListUI
//
//  Created by chenms on 17/8/5.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import "KVORefreshView.h"

static double const kHeight = 60;
static NSTimeInterval const kAnimationDuration = .2;

static NSString * const kKeyPathContentOffset = @"contentOffset";
static NSString * const kKeyPathContentInset = @"contentInset";
static NSString * const kKeyPathContentSize = @"contentSize";
static NSString * const kKeyPathPanState = @"state";

typedef NS_ENUM(NSUInteger, KVORefreshViewStatus) {
    KVORefreshViewStatusNormal = 0,
    KVORefreshViewStatusPulling,
    KVORefreshViewStatusLoading,
};

@interface KVORefreshView ()
@property (nonatomic) KVORefreshViewStatus status;
@property (nonatomic) UILabel *label;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic) BOOL originalAlwaysBounceVertical;
@end

@implementation KVORefreshView

+ (instancetype)refreshView {
    return [self new];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, -kHeight, CGRectGetWidth([UIScreen mainScreen].bounds), kHeight)];
    if (self) {
        self.backgroundColor = [UIColor brownColor];
        self.status = KVORefreshViewStatusNormal;
        
        [self addSubview:self.label];
        self.label.frame = self.bounds;
    }
    
    return self;
}

#pragma mark - Life Cycle
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview && ![newSuperview isKindOfClass:[UIScrollView class]]) {
        return;
    }

    self.scrollView.alwaysBounceVertical = self.originalAlwaysBounceVertical;
    [self removeKVO:self.scrollView];
    
    if (newSuperview) {
        self.scrollView = (UIScrollView *)newSuperview;
        self.originalAlwaysBounceVertical = self.scrollView.alwaysBounceVertical;
        self.scrollView.alwaysBounceVertical = YES;
        [self addKVO:self.scrollView];
    }
}

#pragma mark - KVO
- (void)addKVO:(UIScrollView *)scrollView {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew;
    [scrollView addObserver:self forKeyPath:kKeyPathContentOffset options:options context:nil];
    [scrollView.panGestureRecognizer addObserver:self forKeyPath:kKeyPathPanState options:options context:nil];
}

- (void)removeKVO:(UIScrollView *)scrollView {
    [scrollView removeObserver:self forKeyPath:kKeyPathContentOffset];
    [scrollView.panGestureRecognizer removeObserver:self forKeyPath:kKeyPathPanState];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.hidden) {
        return;
    }
    if ([keyPath isEqualToString:kKeyPathContentOffset]) {
        [self scrollViewContentOffsetDidChange:change];
    } else if ([keyPath isEqualToString:kKeyPathPanState]) {
        [self scrollViewPanStateDidChange:change];
    }
}

#pragma mark - ScrollView
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change {
    [self scrollViewDidScroll:self.scrollView];
}

- (void)scrollViewPanStateDidChange:(NSDictionary *)change {
    if (self.scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self scrollViewDidEndDragging:self.scrollView];
    }
}

#pragma mark - Public
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.status == KVORefreshViewStatusLoading) {
        UIEdgeInsets inset = scrollView.contentInset;
        inset.top = fmin(fmax(scrollView.contentOffset.y * -1, 0), kHeight);
        scrollView.contentInset = inset;
        return;
    }
    
    if (!scrollView.isDragging) {
        return;
    }
    
    if (scrollView.contentOffset.y < -kHeight) {
        if (self.status == KVORefreshViewStatusNormal) {
            self.status = KVORefreshViewStatusPulling;
        }
    } else {
        if (self.status == KVORefreshViewStatusPulling) {
            self.status = KVORefreshViewStatusNormal;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView {
    if (self.status == KVORefreshViewStatusLoading) {
        return;
    }
    
    if (scrollView.contentOffset.y < -kHeight) {
        if (self.didTriggerRefreshBlock) {
            self.status = KVORefreshViewStatusLoading;
            UIEdgeInsets inset = scrollView.contentInset;
            inset.top = kHeight;
            scrollView.contentInset = inset;
            self.didTriggerRefreshBlock();
        }
    }
}

- (void)endRefresh:(UIScrollView *)scrollView {
    self.status = KVORefreshViewStatusNormal;
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        UIEdgeInsets inset = scrollView.contentInset;
        inset.top = 0;
        scrollView.contentInset = inset;
    }];
}

- (void)beginRefresh:(UIScrollView *)scrollView {
    if (self.status == KVORefreshViewStatusLoading) {
        return;
    }
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        scrollView.contentOffset = CGPointMake(0, -kHeight);
        
        self.status = KVORefreshViewStatusLoading;
        UIEdgeInsets inset = scrollView.contentInset;
        inset.top = kHeight;
        scrollView.contentInset = inset;
    }];
}

#pragma mark - Status
- (void)setStatus:(KVORefreshViewStatus)status {
    _status = status;
    
    switch (status) {
        case KVORefreshViewStatusNormal:
            self.label.text = @"下拉即可刷新";
            break;
        case KVORefreshViewStatusPulling:
            self.label.text = @"松开即可刷新";
            break;
        case KVORefreshViewStatusLoading:
            self.label.text = @"加载中";
            break;
        default:
            break;
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

#pragma mark - Life Cycle
- (void)dealloc {
    [self removeKVO:self.scrollView];
}

@end
