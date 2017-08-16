//
//  GroupKVOAutoLoadMoreView.h
//  MHelloListUI
//
//  Created by Chen,Meisong on 2017/8/16.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupKVOAutoLoadMoreView : UIView
@property (nonatomic, copy) void(^didTriggerLoadMoreBlock)(void);
@property (nonatomic, copy) BOOL(^canLoadMore)(void);
+ (instancetype)loadMoreView;
- (void)endLoadMore;
@end
