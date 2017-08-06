//
//  KVORefreshView.h
//  MHelloListUI
//
//  Created by chenms on 17/8/5.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KVORefreshView : UIView
@property (nonatomic, copy) void(^didTriggerRefreshBlock)(void);
+ (instancetype)refreshView;
- (void)endRefresh;
- (void)beginRefresh;
@end
