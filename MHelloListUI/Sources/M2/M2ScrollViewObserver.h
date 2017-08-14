//
//  M2ScrollViewObserver.h
//  MHelloListUI
//
//  Created by Chen,Meisong on 2017/8/11.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface M2ScrollViewObserver : NSObject
@property (nonatomic, copy) void(^scrollViewDidScrollBlock)(UIScrollView *scrollView);
@property (nonatomic, copy) void(^scrollViewDidEndDraggingBlock)(UIScrollView *scrollView);
@property (nonatomic, copy) void(^scrollViewDidChangeContentSizeBlock)(UIScrollView *scrollView);
- (void)addKVOForScrollView:(UIScrollView *)scrollView;
- (void)removeKVOForScrollView:(UIScrollView *)scrollView;
@end
