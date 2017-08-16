//
//  Header.m
//  MHelloListUI
//
//  Created by Chen,Meisong on 2017/8/16.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import "Header.h"

@interface Header ()
@property (nonatomic) UIButton *button;
@end

@implementation Header

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.button];
    }
    
    return self;
}


#pragma mark - Init
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.button.frame = self.bounds;
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
        _button = [UIButton buttonWithType:UIButtonTypeSystem];
        [_button setTitle:@"没有新数据，点击Header xxx" forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(onTap) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _button;
}

@end
