//
//  GroupKVORefreshView.h
//  MHelloListUI
//
//  Created by Chen,Meisong on 2017/8/16.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupKVORefreshView : UIView
@property (nonatomic, copy) void(^didTriggerRefreshBlock)(void);
@property (nonatomic, copy) BOOL(^canRefresh)(void);
+ (instancetype)refreshView;
- (void)endRefresh;
- (void)beginRefresh;
@end
