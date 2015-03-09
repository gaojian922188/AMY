//
//  ReusedCycleScrollView.m
//  PPTVCoreUI
//
//  Created by gan lambert on 14-2-10.
//  Copyright (c) 2014年 PPLive Corporation. All rights reserved.
//

#import "ReusedCycleScrollView.h"
@interface ReusedCycleScrollView ()

@property (nonatomic,strong)NSMutableArray *reUsedItemArray;

@end
@implementation ReusedCycleScrollView


- (void)reloadData
{
    self.reUsedItemArray = nil;
    [super reloadData];
}


- (void)loadData
{
    //从scrollView上移除所有的subview
    NSArray *subViews = [_scrollView subviews];
    
    if ([subViews count] != 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self getDisplayImagesWithCurpage:_curPage];
    
    for (int i = 0; i < [_curViews count]; i++) {
        UIView *v = [_curViews objectAtIndex:i];
        v.frame = CGRectOffset(v.bounds, v.frame.size.width * (self.showingPageOffLeftBound ? (i - 1) : i), 0);
        [_scrollView addSubview:v];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 6) {
        // 避免6.0以上版本scrollview滚动结束时晃动，5.0上无法修复这个问题.
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:NO];
    } else {
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
    }
}

- (void)getDisplayImagesWithCurpage:(int)page
{
    int leftOffBound = [self validPageValue:_curPage - 2];
    int pre  = [self validPageValue:_curPage - 1];
    int last = [self validPageValue:_curPage + 1];
    int rightOffBound = [self validPageValue:_curPage + 2];
    
    if (!_curViews) {
        _curViews = [[NSMutableArray alloc] init];
    }
    
    [_curViews removeAllObjects];
    

    
    if (_totalPages < 3 && [self.reUsedItemArray count]) {
        
        [self.datasource pageAtIndex:page];
      
        [_curViews addObjectsFromArray:self.reUsedItemArray];
    } else {
        if (self.showingPageOffLeftBound && [self.datasource pageAtIndex:leftOffBound]) {
            [_curViews addObject:[self.datasource pageAtIndex:leftOffBound]];
        }
        
        UIView *v  = [self.datasource pageAtIndex:pre];
        if (v) {
            [_curViews addObject:v];
        }
        
        v = [self.datasource pageAtIndex:page];
        if (v) {
            [_curViews addObject:v];
        }
        
        v = [self.datasource pageAtIndex:last];
        if (v) {
            [_curViews addObject:v];
        }
        //当页面等于2的时候多加一个处理需要4个复用类似于 1212
        if ((self.showingPageOffRightBound && [self.datasource pageAtIndex:rightOffBound]) || (_totalPages == 2 && [_curViews count] %2 ==1)) {
            [_curViews addObject:[self.datasource pageAtIndex:rightOffBound]];
        }
    }

    
    if (!self.reUsedItemArray) {
        self.reUsedItemArray = [NSMutableArray arrayWithArray:_curViews];
        if (!self.isNotNeedSelectAction) {
            for (UIView *view in self.reUsedItemArray) {
                view.userInteractionEnabled = YES;
                UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                       action:@selector(click:)];
                [view addGestureRecognizer:tapGestureRecognizer];
            }
        }

    }
}
- (void)click:(UIView *)view
{
    if ([self.delegate respondsToSelector:@selector(cycleScrollViewClickAtPage:)]) {
        [self.delegate cycleScrollViewClickAtPage:[self validPageValue:_curPage]];
    }
}


-(UIView *)getReusableItem:(NSInteger)index
{
    int leftOffBound = [self validPageValue:_curPage - 2];
    int pre  = [self validPageValue:_curPage - 1];
    int last = [self validPageValue:_curPage + 1];
    int rightOffBound = [self validPageValue:_curPage + 2];
    NSInteger realIndex = 0;
    
    NSInteger realIndexOffset = 0;
    
    if ( self.showingPageOffLeftBound ) {
        realIndexOffset ++;
    }
    
    if (index == pre) {
        realIndex = realIndexOffset;
    } else if (index == [self validPageValue:_curPage]) {
        realIndex = realIndexOffset + 1;
    } else if (index == last) {
        realIndex = realIndexOffset + 2;
    } else if (index == leftOffBound) {
        realIndex = 0;
    } else if (index == rightOffBound) {
        realIndex = [self.reUsedItemArray count] - 1;
    }
    
    
    if (!self.reUsedItemArray) {
        return nil;
    } else {
        if (realIndex >= 0 && [self.reUsedItemArray count] >=3) {
            return [self.reUsedItemArray objectAtIndex:realIndex];
        }
        
    }
    return nil;
}
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    if (_totalPages) {
        CGFloat x = aScrollView.contentOffset.x;
        
        //往下翻一张
        if (x >= (2 * self.frame.size.width)){
            _curPage = [self validPageValue:_curPage + 1];
            if ([self.reUsedItemArray count] >= 3) {
                id object = [self.reUsedItemArray objectAtIndex:0];
                [self.reUsedItemArray removeObjectAtIndex:0];
                [self.reUsedItemArray addObject:object];
            }
            [self loadData];
        }
        
        //往上翻
        if (x <= 0.f) {
            _curPage = [self validPageValue:_curPage - 1];
            if ([self.reUsedItemArray count] >= 3) {
                id object = [self.reUsedItemArray lastObject];
                [self.reUsedItemArray removeObjectAtIndex:[self.reUsedItemArray count]-1];
                [self.reUsedItemArray insertObject:object atIndex:0];
            }
            [self loadData];
        }
        
        if (!self.isScrolling) {
            // 如果不是触摸造成的滚动, 调用自动下一集的delegate
            if ([self.delegate respondsToSelector:@selector(cycleScrollViewDidAutoSwitchToNextPage:)]) {
                [self.delegate cycleScrollViewDidAutoSwitchToNextPage:self];
            }
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
