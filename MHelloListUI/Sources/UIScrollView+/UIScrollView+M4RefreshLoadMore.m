//
//  UIScrollView+M4RefreshLoadMore.m
//  MHelloListUI
//
//  Created by Chen,Meisong on 2017/8/16.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import "UIScrollView+M4RefreshLoadMore.h"
#import <objc/runtime.h>

@implementation UIScrollView (M4RefreshLoadMore)

static char const M4RefreshViewKey = '\0';
- (void)setM4_refreshView:(KVORefreshView *)m4_refreshView {
    if (m4_refreshView != self.m4_refreshView) {
        [self.m4_refreshView removeFromSuperview];
        [self addSubview:m4_refreshView];
        
        objc_setAssociatedObject(self, &M4RefreshViewKey, m4_refreshView, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (KVORefreshView *)m4_refreshView {
    return objc_getAssociatedObject(self, &M4RefreshViewKey);
}

@end
