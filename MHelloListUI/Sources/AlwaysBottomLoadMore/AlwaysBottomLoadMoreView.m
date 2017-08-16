//
//  AlwaysBottomLoadMoreView.m
//  MHelloListUI
//
//  Created by Chen,Meisong on 2017/8/16.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import "AlwaysBottomLoadMoreView.h"

static double const kHeight = 60;

static NSString * const kKeyPathContentOffset = @"contentOffset";
static NSString * const kKeyPathContentSize = @"contentSize";

typedef NS_ENUM(NSUInteger, AlwaysBottomLoadMoreViewStatus) {
    AlwaysBottomLoadMoreViewStatusNormal = 0,
    AlwaysBottomLoadMoreViewStatusLoading,
};

@interface AlwaysBottomLoadMoreView ()
@property (nonatomic) AlwaysBottomLoadMoreViewStatus status;
@property (nonatomic) UILabel *label;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic) BOOL originalAlwaysBounceVertical;
@end


@implementation AlwaysBottomLoadMoreView

+ (instancetype)loadMoreView {
    return [self new];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), kHeight)];
    if (self) {
        self.backgroundColor = [UIColor brownColor];
        self.status = AlwaysBottomLoadMoreViewStatusNormal;
        
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
    if (self.status == AlwaysBottomLoadMoreViewStatusLoading) {
        return;
    }
    
    if (!scrollView.isDragging) {
        return;
    }
    
    // 不满一屏
    if (scrollView.contentSize.height < CGRectGetHeight(scrollView.bounds)) {
        if (scrollView.contentOffset.y > kHeight) {
            [self tryLoad];
        }
    }
    // 满一屏
    else {
        if (CGRectGetHeight(self.scrollView.bounds) + scrollView.contentOffset.y - self.scrollView.contentSize.height > kHeight) {
            [self tryLoad];
        }
    }
}

- (void)tryLoad {
    if (self.status == AlwaysBottomLoadMoreViewStatusNormal) {
        if (self.didTriggerLoadMoreBlock) {
            self.status = AlwaysBottomLoadMoreViewStatusLoading;
            self.didTriggerLoadMoreBlock();
        }
    }
}

- (void)scrollViewDidChangeContentSize:(UIScrollView *)scrollView {
    // y
    double scrollContentHeight = scrollView.contentSize.height;
    double scrollHeight = CGRectGetHeight(scrollView.bounds);
    double height = fmax(scrollHeight, scrollContentHeight);
    
    CGRect frame = self.frame;
    frame.origin.y = height;
    self.frame = frame;
    
    // inset
    UIEdgeInsets inset = self.scrollView.contentInset;
    // 满一屏
    if (scrollContentHeight > scrollHeight) {
        inset.bottom = kHeight;
    }
    // 不满一屏
    else {
        inset.bottom = scrollHeight - scrollContentHeight + kHeight;
    }
    
    self.scrollView.contentInset = inset;
}

#pragma mark - Public
- (void)endLoadMore {
    self.status = AlwaysBottomLoadMoreViewStatusNormal;
}


#pragma mark - Status
- (void)setStatus:(AlwaysBottomLoadMoreViewStatus)status {
    _status = status;
    
    switch (status) {
        case AlwaysBottomLoadMoreViewStatusNormal:
            self.label.text = @"上拉即可加载";
            break;
        case AlwaysBottomLoadMoreViewStatusLoading:
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
