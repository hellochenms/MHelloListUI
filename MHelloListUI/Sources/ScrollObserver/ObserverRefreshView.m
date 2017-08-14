//
//  ObserverRefreshView.m
//  MHelloListUI
//
//  Created by Chen,Meisong on 2017/8/11.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import "ObserverRefreshView.h"

static double const kHeight = 60;
static double const kAnimationDuration = .2;

@interface ObserverRefreshView ()
@property (nonatomic) M2ScrollViewObserver *scrollViewObserver;
@property (nonatomic) ObserverRefreshViewStatus status;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic) BOOL originalAlwaysBounceVertical;
@end

@implementation ObserverRefreshView

+ (instancetype)refreshView {
    return [self new];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, -kHeight, CGRectGetWidth([UIScreen mainScreen].bounds), kHeight)];
    if (self) {
        self.backgroundColor = [UIColor brownColor];
        self.status = ObserverRefreshViewStatusNormal;
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
    // 为什么用self.superview：weak的scorllView现在可能返回nil了，但self.superview依然可以拿到值
    // 尚不清楚原因
    [self.scrollViewObserver removeKVOForScrollView:(UIScrollView *)self.superview];
    
    if (newSuperview) {
        self.scrollView = (UIScrollView *)newSuperview;
        self.originalAlwaysBounceVertical = self.scrollView.alwaysBounceVertical;
        self.scrollView.alwaysBounceVertical = YES;
        [self.scrollViewObserver addKVOForScrollView:self.scrollView];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
}

#pragma mark - Public
- (void)endRefresh{
    self.status = ObserverRefreshViewStatusNormal;
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.top = 0;
        self.scrollView.contentInset = inset;
    }];
}

- (void)beginRefresh {
    if (self.status == ObserverRefreshViewStatusLoading) {
        return;
    }
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.scrollView.contentOffset = CGPointMake(0, -kHeight);
        
        self.status = ObserverRefreshViewStatusLoading;
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.top = kHeight;
        self.scrollView.contentInset = inset;
    }];
}

#pragma mark - Status
- (void)setStatus:(ObserverRefreshViewStatus)status {
    _status = status;
    [self.contentView refreshUIWithStatus:status];
}

#pragma mark - Setter
- (M2ScrollViewObserver *)scrollViewObserver {
    if (!_scrollViewObserver) {
        _scrollViewObserver = [M2ScrollViewObserver new];
        __weak typeof(self) weakSelf = self;
        _scrollViewObserver.scrollViewDidScrollBlock = ^(UIScrollView *scrollView) {
            if (weakSelf.status == ObserverRefreshViewStatusLoading) {
                UIEdgeInsets inset = scrollView.contentInset;
                inset.top = fmin(fmax(scrollView.contentOffset.y * -1, 0), kHeight);
                scrollView.contentInset = inset;
                return;
            }
            
            if (!scrollView.isDragging) {
                return;
            }
            
            if (scrollView.contentOffset.y < -kHeight) {
                if (weakSelf.status == ObserverRefreshViewStatusNormal) {
                    weakSelf.status = ObserverRefreshViewStatusPulling;
                }
            } else {
                if (weakSelf.status == ObserverRefreshViewStatusPulling) {
                    weakSelf.status = ObserverRefreshViewStatusNormal;
                }
            }
        };
        _scrollViewObserver.scrollViewDidEndDraggingBlock = ^(UIScrollView *scrollView) {
            if (weakSelf.status == ObserverRefreshViewStatusLoading) {
                return;
            }
            
            if (scrollView.contentOffset.y < -kHeight) {
                if (weakSelf.didTriggerRefreshBlock) {
                    weakSelf.status = ObserverRefreshViewStatusLoading;
                    UIEdgeInsets inset = scrollView.contentInset;
                    inset.top = kHeight;
                    scrollView.contentInset = inset;
                    weakSelf.didTriggerRefreshBlock();
                }
            }
        };
    }
    
    return _scrollViewObserver;
}

- (void)setContentView:(UIView<ObserverRefreshContentViewProtocol> *)contentView {
    [_contentView removeFromSuperview];
    _contentView = contentView;
    [self addSubview:_contentView];
}

@end
