//
//  M2ScrollViewObserver.m
//  MHelloListUI
//
//  Created by Chen,Meisong on 2017/8/11.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import "M2ScrollViewObserver.h"

static NSString * const kKeyPathContentOffset = @"contentOffset";
static NSString * const kKeyPathPanState = @"state";
static NSString * const kKeyPathContentSize = @"contentSize";

@interface M2ScrollViewObserver ()
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic) UIPanGestureRecognizer *pan;
@end

@implementation M2ScrollViewObserver
- (void)addKVOForScrollView:(UIScrollView *)scrollView {
    self.scrollView = scrollView;
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew;
    [scrollView addObserver:self forKeyPath:kKeyPathContentOffset options:options context:nil];
    self.pan = scrollView.panGestureRecognizer;
    [self.pan addObserver:self forKeyPath:kKeyPathPanState options:options context:nil];
    [scrollView addObserver:self forKeyPath:kKeyPathContentSize options:options context:nil];
}

- (void)removeKVOForScrollView:(UIScrollView *)scrollView {
    [scrollView removeObserver:self forKeyPath:kKeyPathContentOffset];
    [self.pan removeObserver:self forKeyPath:kKeyPathPanState];
    self.pan = nil;
    [scrollView removeObserver:self forKeyPath:kKeyPathContentSize];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kKeyPathContentOffset]) {
        if (self.scrollViewDidScrollBlock) {
            self.scrollViewDidScrollBlock(self.scrollView);
        }
    } else if ([keyPath isEqualToString:kKeyPathPanState]) {
        if (self.pan.state == UIGestureRecognizerStateEnded) {
            if (self.scrollViewDidEndDraggingBlock) {
                self.scrollViewDidEndDraggingBlock(self.scrollView);
            }
        }
    } else if ([keyPath isEqualToString:kKeyPathContentSize]) {
        if (self.scrollViewDidChangeContentSizeBlock) {
            self.scrollViewDidChangeContentSizeBlock(self.scrollView);
        }
    }
}

@end
