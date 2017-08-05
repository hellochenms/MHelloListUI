//
//  EGORefreshView.m
//  MHelloListUI
//
//  Created by chenms on 17/8/5.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import "EGORefreshView.h"

static double const kHeight = 60;

typedef NS_ENUM(NSUInteger, EGORefreshViewStatus) {
    EGORefreshViewStatusNormal = 0,
    EGORefreshViewStatusPulling,
    EGORefreshViewStatusLoading,
};

@interface EGORefreshView ()
@property (nonatomic) EGORefreshViewStatus status;
@property (nonatomic) UILabel *label;
@end

@implementation EGORefreshView

+ (instancetype)refreshView {
    return [self new];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, -kHeight, CGRectGetWidth([UIScreen mainScreen].bounds), kHeight)];
    if (self) {
        self.backgroundColor = [UIColor brownColor];
        self.status = EGORefreshViewStatusNormal;
        
        [self addSubview:self.label];
        self.label.frame = self.bounds;
    }
    
    return self;
}

#pragma mark - Public
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.status == EGORefreshViewStatusLoading) {
        UIEdgeInsets inset = scrollView.contentInset;
        inset.top = fmin(fmax(scrollView.contentOffset.y * -1, 0), kHeight);
        scrollView.contentInset = inset;
        return;
    }
    
    if (!scrollView.isDragging) {
        return;
    }
    
    if (scrollView.contentOffset.y < -kHeight) {
        if (self.status == EGORefreshViewStatusNormal) {
            self.status = EGORefreshViewStatusPulling;
        }
    } else {
        if (self.status == EGORefreshViewStatusPulling) {
            self.status = EGORefreshViewStatusNormal;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView {
    if (self.status == EGORefreshViewStatusLoading) {
        return;
    }
    
    if (scrollView.contentOffset.y < -kHeight) {
        if (self.didTriggerRefreshBlock) {
            self.status = EGORefreshViewStatusLoading;
            UIEdgeInsets inset = scrollView.contentInset;
            inset.top = kHeight;
            scrollView.contentInset = inset;
            self.didTriggerRefreshBlock();
        }
    }
}

- (void)endRefresh:(UIScrollView *)scrollView {
    self.status = EGORefreshViewStatusNormal;
    
    [UIView animateWithDuration:0.2 animations:^{
        UIEdgeInsets inset = scrollView.contentInset;
        inset.top = 0;
        scrollView.contentInset = inset;
    }];
}

#pragma mark - Status
- (void)setStatus:(EGORefreshViewStatus)status {
    _status = status;
    
    switch (status) {
        case EGORefreshViewStatusNormal:
            self.label.text = @"下拉即可刷新";
            break;
        case EGORefreshViewStatusPulling:
            self.label.text = @"松开即可刷新";
            break;
        case EGORefreshViewStatusLoading:
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
