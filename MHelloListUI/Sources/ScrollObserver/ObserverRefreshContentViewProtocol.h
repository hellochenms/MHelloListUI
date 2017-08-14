//
//  ObserverRefreshViewProtocol.h
//  MHelloListUI
//
//  Created by Chen,Meisong on 2017/8/11.
//  Copyright © 2017年 chenms.m2. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ObserverRefreshViewStatus) {
    ObserverRefreshViewStatusNormal = 0,
    ObserverRefreshViewStatusPulling,
    ObserverRefreshViewStatusLoading,
};

@protocol ObserverRefreshContentViewProtocol <NSObject>
- (void)refreshUIWithStatus:(ObserverRefreshViewStatus)status;
@end
