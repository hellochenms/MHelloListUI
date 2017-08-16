//
//  HeaderKVORefreshView.m
//  MHelloListUI
//
//  Created by Chen,Meisong on 2017/8/16.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import "HeaderKVORefreshView.h"

static double const kHeight = 60;
static double const kAnimationDuration = .2;

static NSString * const kKeyPathContentOffset = @"contentOffset";
static NSString * const kKeyPathPanState = @"state";

typedef NS_ENUM(NSUInteger, HeaderKVORefreshViewStatus) {
    HeaderKVORefreshViewStatusNormal = 0,
    HeaderKVORefreshViewStatusPulling,
    HeaderKVORefreshViewStatusLoading,
};

@interface HeaderKVORefreshView ()
@property (nonatomic) HeaderKVORefreshViewStatus status;
@property (nonatomic) UILabel *label;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic) BOOL originalAlwaysBounceVertical;
@property (nonatomic) UIPanGestureRecognizer *pan; // 无法确定系统释放时机，可能导致KVO问题，故用strong变量维护
@end

@implementation HeaderKVORefreshView

+ (instancetype)refreshView {
    return [self new];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, -kHeight, CGRectGetWidth([UIScreen mainScreen].bounds), kHeight)];
    if (self) {
        self.backgroundColor = [UIColor brownColor];
        self.status = HeaderKVORefreshViewStatusNormal;
        
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
    if (self.hidden) {
        return;
    }
    
    if (self.status == HeaderKVORefreshViewStatusLoading) {
        UIEdgeInsets inset = scrollView.contentInset;
        inset.top = fmin(fmax(scrollView.contentOffset.y * -1, 0), kHeight);
        scrollView.contentInset = inset;
        return;
    }
    
    if (!scrollView.isDragging) {
        return;
    }
    
    if (scrollView.contentOffset.y < -kHeight) {
        if (self.status == HeaderKVORefreshViewStatusNormal) {
            self.status = HeaderKVORefreshViewStatusPulling;
        }
    } else {
        if (self.status == HeaderKVORefreshViewStatusPulling) {
            self.status = HeaderKVORefreshViewStatusNormal;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView {
    if (self.hidden) {
        return;
    }
    
    if (self.status == HeaderKVORefreshViewStatusLoading) {
        return;
    }
    
    if (self.canRefresh && !self.canRefresh()) {
        return;
    }
    
    if (scrollView.contentOffset.y < -kHeight) {
        if (self.didTriggerRefreshBlock) {
            self.status = HeaderKVORefreshViewStatusLoading;
            UIEdgeInsets inset = scrollView.contentInset;
            inset.top = kHeight;
            scrollView.contentInset = inset;
            self.didTriggerRefreshBlock();
        }
    }
}

#pragma mark - Public
- (void)endRefresh {
    self.status = HeaderKVORefreshViewStatusNormal;
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.top = 0;
        self.scrollView.contentInset = inset;
    }];
}

- (void)beginRefresh {
    if (self.status == HeaderKVORefreshViewStatusLoading) {
        return;
    }
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.scrollView.contentOffset = CGPointMake(0, -kHeight);
        
        self.status = HeaderKVORefreshViewStatusLoading;
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.top = kHeight;
        self.scrollView.contentInset = inset;
    }];
}

#pragma mark - Status
- (void)setStatus:(HeaderKVORefreshViewStatus)status {
    _status = status;
    
    switch (status) {
        case HeaderKVORefreshViewStatusNormal:
            self.label.text = @"下拉即可刷新";
            break;
        case HeaderKVORefreshViewStatusPulling:
            self.label.text = @"松开即可刷新";
            break;
        case HeaderKVORefreshViewStatusLoading:
            self.label.text = @"刷新中";
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

@end
