//
//  XLCycleScrollView.h
//  CycleScrollViewDemo
//
//  Created by xie liang on 9/14/12.
//  Copyright (c) 2012 xie liang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XLCycleScrollViewDelegate;
@protocol XLCycleScrollViewDatasource;

@interface XLCycleScrollView : UIView<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
        
    NSInteger _totalPages;
    NSInteger _curPage;
    
    NSMutableArray *_curViews;
}

@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, weak, setter = setDataource:) id<XLCycleScrollViewDatasource> datasource;
@property (nonatomic, weak, setter = setDelegate:) id<XLCycleScrollViewDelegate> delegate;

@property (nonatomic, assign) BOOL showingPageOffRightBound;
@property (nonatomic, assign) BOOL showingPageOffLeftBound;

@property (nonatomic, assign) BOOL isScrolling;

@property (nonatomic, assign) NSTimeInterval autoSwitchPageDuration;

- (void)reloadData;
- (void)setViewContent:(UIView *)view atIndex:(NSInteger)index;
- (void)setScrollFrame:(CGRect)frame;
- (int)validPageValue:(NSInteger)value;

- (void)startCycleScrolling;
- (void)stopCycleSCrolling;

@end

@protocol XLCycleScrollViewDelegate <NSObject>

@optional
- (void)cycleScrollViewDidEndDecelerating:(XLCycleScrollView *)csView;
- (void)cycleScrollViewWillBeginDragging:(XLCycleScrollView *)csView;
- (void)cycleScrollViewDidAutoSwitchToNextPage:(XLCycleScrollView *)csView;

@end

@protocol XLCycleScrollViewDatasource <NSObject>

@required
- (NSInteger)numberOfPages;
- (UIView *)pageAtIndex:(NSInteger)index;

@end
