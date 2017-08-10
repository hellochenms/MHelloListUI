//
//  MultEndStatusLoadMoreView.h
//  MHelloListUI
//
//  Created by Chen,Meisong on 2017/8/10.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultEndStatusLoadMoreView : UIView
@property (nonatomic, copy) void(^didTriggerLoadMoreBlock)(void);
@property (nonatomic, copy) void(^onTapNoMoreButtonBlock)(void);
+ (instancetype)loadMoreView;
- (void)endLoadMore;
- (void)endLoadMoreWithNoMoreLabel;
- (void)endLoadMoreWithNoMoreButton;
- (void)reset;
@end
