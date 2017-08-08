//
//  KVOAutoLoadMoreView.h
//  MHelloListUI
//
//  Created by chenms on 17/8/8.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KVOAutoLoadMoreView : UIView
@property (nonatomic, copy) void(^didTriggerLoadMoreBlock)(void);
+ (instancetype)loadMoreView;
- (void)endLoadMore;
@end
