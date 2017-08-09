//
//  ExtraView.m
//  MHelloListUI
//
//  Created by Chen,Meisong on 2017/8/9.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import "ExtraView.h"



@interface ExtraView ()
@property (nonatomic) UIButton *button;
@end

@implementation ExtraView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.button];
        [self layoutMySubViews];
    }
    
    return self;
}

- (void)layoutMySubViews {
    NSDictionary *metrics = @{@"hm": @20, @"vm": @10};
    NSDictionary *views = @{@"button": self.button};
    
    NSString *hLayout = @"H:|-hm-[button]-hm-|";
    NSArray *hContraints = [NSLayoutConstraint constraintsWithVisualFormat:hLayout options:0 metrics:metrics views:views];
    [self addConstraints:hContraints];
    NSString *vLayout = @"V:|-vm-[button]-vm-|";
    NSArray *vContraints = [NSLayoutConstraint constraintsWithVisualFormat:vLayout options:0 metrics:metrics views:views];
    [self addConstraints:vContraints];
}

#pragma mark - Event
- (void)onTap {
    if (self.onTapBlock) {
        self.onTapBlock();
    }
}

#pragma mark - Getter
- (UIButton *)button {
    if(!_button){
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setTitle:@"button" forState:UIControlStateNormal];
        _button.backgroundColor = [UIColor grayColor];
        [_button addTarget:self action:@selector(onTap) forControlEvents:UIControlEventTouchUpInside];
        _button.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return _button;
}

@end
