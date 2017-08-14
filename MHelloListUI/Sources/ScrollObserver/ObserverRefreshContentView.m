//
//  ObserverRefreshContentView.m
//  MHelloListUI
//
//  Created by Chen,Meisong on 2017/8/11.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import "ObserverRefreshContentView.h"

@interface ObserverRefreshContentView ()
@property (nonatomic) UILabel *label;
@end

@implementation ObserverRefreshContentView

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.label];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.label.frame = self.bounds;
}

#pragma mark - Override
- (void)refreshUIWithStatus:(ObserverRefreshViewStatus)status {
    switch (status) {
        case ObserverRefreshViewStatusNormal:
            self.label.text = @"下拉即可刷新";
            break;
        case ObserverRefreshViewStatusPulling:
            self.label.text = @"松开即可刷新";
            break;
        case ObserverRefreshViewStatusLoading:
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
