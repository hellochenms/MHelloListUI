//
//  ShorterThanScreenCanLoadMoreView.h
//  MHelloListUI
//
//  Created by Chen,Meisong on 2017/8/15.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShorterThanScreenCanLoadMoreView : UIView
@property (nonatomic, copy) void(^didTriggerLoadMoreBlock)(void);
+ (instancetype)loadMoreView;
- (void)endLoadMore;
@end
