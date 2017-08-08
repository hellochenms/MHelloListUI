//
//  KVOAutoLoadMoreView.m
//  MHelloListUI
//
//  Created by chenms on 17/8/8.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import "KVOAutoLoadMoreView.h"

static double const kHeight = 60;
static double const kAnimationDuration = .2;

static NSString * const kKeyPathContentOffset = @"contentOffset";
static NSString * const kKeyPathContentSize = @"contentSize";
static NSString * const kKeyPathPanState = @"state";

typedef NS_ENUM(NSUInteger, KVOAutoLoadMoreViewStatus) {
    KVOAutoLoadMoreViewStatusNormal = 0,
    KVOAutoLoadMoreViewStatusPulling,
    KVOAutoLoadMoreViewStatusLoading,
};

@interface KVOAutoLoadMoreView ()
@property (nonatomic) KVOAutoLoadMoreViewStatus status;
@property (nonatomic) UILabel *label;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic) BOOL originalAlwaysBounceVertical;
@property (nonatomic) UIPanGestureRecognizer *pan;
@end


@implementation KVOAutoLoadMoreView

+ (instancetype)loadMoreView {
    return [self new];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), kHeight)];
    if (self) {
        self.backgroundColor = [UIColor brownColor];
        self.status = KVOAutoLoadMoreViewStatusNormal;
        
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
        
        [self scrollViewDidChangeContentSize:self.scrollView];
    }
}

#pragma mark - KVO
- (void)addKVO {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew;
    [self.scrollView addObserver:self forKeyPath:kKeyPathContentOffset options:options context:nil];
    [self.scrollView addObserver:self forKeyPath:kKeyPathContentSize options:options context:nil];
    self.pan = self.scrollView.panGestureRecognizer;
    [self.pan addObserver:self forKeyPath:kKeyPathPanState options:options context:nil];
}

- (void)removeKVO {
    [self.superview removeObserver:self forKeyPath:kKeyPathContentOffset];
    [self.superview removeObserver:self forKeyPath:kKeyPathContentSize];
    [self.pan removeObserver:self forKeyPath:kKeyPathPanState];
    self.pan = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (!self.hidden) {
        if ([keyPath isEqualToString:kKeyPathContentOffset]) {
            [self scrollViewDidScroll:self.scrollView];
        } else if ([keyPath isEqualToString:kKeyPathPanState]) {
            if (self.scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
                [self scrollViewDidEndDragging:self.scrollView];
            }
        }
    }
    if ([keyPath isEqualToString:kKeyPathContentSize]) {
        [self scrollViewDidChangeContentSize:self.scrollView];
    }
}

#pragma mark - ScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.status == KVOAutoLoadMoreViewStatusLoading) {
        UIEdgeInsets inset = scrollView.contentInset;
        inset.bottom = fmin(fmax(CGRectGetHeight(self.scrollView.bounds) + scrollView.contentOffset.y - self.scrollView.contentSize.height, 0), kHeight);
        scrollView.contentInset = inset;
        return;
    }
    
    if (!scrollView.isDragging) {
        return;
    }
    
    if (CGRectGetHeight(self.scrollView.bounds) + scrollView.contentOffset.y - self.scrollView.contentSize.height > kHeight) {
        if (self.status == KVOAutoLoadMoreViewStatusNormal) {
            self.status = KVOAutoLoadMoreViewStatusPulling;
        }
    } else {
        if (self.status == KVOAutoLoadMoreViewStatusPulling) {
            self.status = KVOAutoLoadMoreViewStatusNormal;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView {
    if (self.status == KVOAutoLoadMoreViewStatusLoading) {
        return;
    }
    
    if (CGRectGetHeight(self.scrollView.bounds) + scrollView.contentOffset.y - self.scrollView.contentSize.height > kHeight) {
        if (self.didTriggerLoadMoreBlock) {
            self.status = KVOAutoLoadMoreViewStatusLoading;
            UIEdgeInsets inset = scrollView.contentInset;
            inset.bottom = kHeight;
            scrollView.contentInset = inset;
            self.didTriggerLoadMoreBlock();
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
    self.status = KVOAutoLoadMoreViewStatusNormal;
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.bottom = 0;
        self.scrollView.contentInset = inset;
    }];
}


#pragma mark - Status
- (void)setStatus:(KVOAutoLoadMoreViewStatus)status {
    _status = status;
    
    switch (status) {
        case KVOAutoLoadMoreViewStatusNormal:
            self.label.text = @"上拉即可加载";
            break;
        case KVOAutoLoadMoreViewStatusPulling:
            self.label.text = @"松开即可加载";
            break;
        case KVOAutoLoadMoreViewStatusLoading:
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

@end
