//
//  ReusedCycleScrollView.h
//  PPTVCoreUI
//
//  Created by gan lambert on 14-2-10.
//  Copyright (c) 2014年 PPLive Corporation. All rights reserved.
//

#import "XLCycleScrollView.h"

@protocol ReusedCycleScrollViewDelegate <XLCycleScrollViewDelegate>

@optional

- (void)cycleScrollViewClickAtPage:(NSInteger)page;

@end

@interface ReusedCycleScrollView : XLCycleScrollView

@property(nonatomic,weak)   id <ReusedCycleScrollViewDelegate>   delegate;

@property(nonatomic,assign)  BOOL isNotNeedSelectAction;

- (UIView *)getReusableItem:(NSInteger)index;


@end


