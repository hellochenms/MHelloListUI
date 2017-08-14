//
//  ObserverRefreshView.h
//  MHelloListUI
//
//  Created by Chen,Meisong on 2017/8/11.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "M2ScrollViewObserver.h"
#import "ObserverRefreshContentViewProtocol.h"
#import "ObserverRefreshContentView.h"

@interface ObserverRefreshView : UIView
@property (nonatomic) UIView<ObserverRefreshContentViewProtocol> *contentView;
@property (nonatomic, copy) void(^didTriggerRefreshBlock)(void);
+ (instancetype)refreshView;
- (void)endRefresh;
- (void)beginRefresh;
@end
