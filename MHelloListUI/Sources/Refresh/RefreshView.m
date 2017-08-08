//
//  RefreshView.m
//  MHelloListUI
//
//  Created by chenms on 17/8/8.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import "RefreshView.h"

static double const kHeight = 60;

typedef NS_ENUM(NSUInteger, RefreshViewStatus) {
    RefreshViewStatusNormal = 0,
    RefreshViewStatusPulling,
    RefreshViewStatusLoading,
};

@interface RefreshView ()
@property (nonatomic) RefreshViewStatus status;
@property (nonatomic) UILabel *label;
@end

@implementation RefreshView

+ (instancetype)refreshView {
    return [self new];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, -kHeight, CGRectGetWidth([UIScreen mainScreen].bounds), kHeight)];
    if (self) {
        self.backgroundColor = [UIColor brownColor];
        self.status = RefreshViewStatusNormal;
        
        [self addSubview:self.label];
        self.label.frame = self.bounds;
    }
    
    return self;
}

#pragma mark - Public
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.status == RefreshViewStatusLoading) {
        return;
    }
    
    if (!scrollView.isDragging) {
        return;
    }
    
    if (scrollView.contentOffset.y < -kHeight) {
        if (self.status == RefreshViewStatusNormal) {
            self.status = RefreshViewStatusPulling;
        }
    } else {
        if (self.status == RefreshViewStatusPulling) {
            self.status = RefreshViewStatusNormal;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView {
    if (self.status == RefreshViewStatusLoading) {
        return;
    }
    
    if (scrollView.contentOffset.y < -kHeight) {
        if (self.didTriggerRefreshBlock) {
            self.status = RefreshViewStatusLoading;
            self.didTriggerRefreshBlock();
        }
    }
}

- (void)endRefresh:(UIScrollView *)scrollView {
    self.status = RefreshViewStatusNormal;
}

#pragma mark - Status
- (void)setStatus:(RefreshViewStatus)status {
    _status = status;
    
    switch (status) {
        case RefreshViewStatusNormal:
            self.label.text = @"下拉即可刷新";
            break;
        case RefreshViewStatusPulling:
            self.label.text = @"松开即可刷新";
            break;
        case RefreshViewStatusLoading:
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
