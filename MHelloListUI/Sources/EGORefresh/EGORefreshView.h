//
//  EGORefreshView.h
//  MHelloListUI
//
//  Created by chenms on 17/8/5.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EGORefreshView : UIView
@property (nonatomic, copy) void(^didTriggerRefreshBlock)(void);
+ (instancetype)refreshView;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)endRefresh:(UIScrollView *)scrollView;
- (void)beginRefresh:(UIScrollView *)scrollView;
@end
