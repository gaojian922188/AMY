//
//  XLCycleScrollView.m
//  CycleScrollViewDemo
//
//  Created by xie liang on 9/14/12.
//  Copyright (c) 2012 xie liang. All rights reserved.
//

#import "XLCycleScrollView.h"

@interface XLCycleScrollView ()



@property (nonatomic, weak) NSTimer *autoSwitchTimer;

@end

@implementation XLCycleScrollView

@synthesize scrollView  = _scrollView;
@synthesize currentPage = _curPage;
@synthesize datasource  = _datasource;
@synthesize delegate    = _delegate;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate    = self;
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollsToTop = NO;
        _scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:_scrollView];

        CGRect rect = self.bounds;
        rect.origin.y    = rect.size.height - 30;
        rect.size.height = 30;

        _curPage = 0;
        
    }
    return self;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate    = self;
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollsToTop = NO;
        _scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:_scrollView];
    }

}

- (void)dealloc
{
    // workaround: 修复如果在scrollview 动画中是否scrollview造成的crash.
    self.datasource = nil;
    self.delegate = nil;
    [self.scrollView setContentOffset:CGPointZero];
    self.scrollView.delegate = nil;
    
    
    [self.autoSwitchTimer invalidate];
}

- (void)setScrollFrame:(CGRect)frame
{
    self.frame = frame;
    _scrollView.frame = self.bounds;
    _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
}

- (void)setDataource:(id<XLCycleScrollViewDatasource> )datasource
{
    _datasource = datasource;
    [self reloadData];
}

- (void)reloadData
{
    _totalPages = [_datasource numberOfPages];
    if (_totalPages == 0) {
        return;
    }
    [self loadData];
    [self startAutoSwitchTimer];
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
        v.frame = CGRectOffset(v.frame, v.frame.size.width * (self.showingPageOffLeftBound ? (i - 1) : i), 0);
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
    
    UIView *v = [_datasource pageAtIndex:leftOffBound];
    if (self.showingPageOffLeftBound && v) {
        [_curViews addObject:v];
    }
    
    v = [_datasource pageAtIndex:pre];
    if (v) {
        [_curViews addObject:v];
    }
    
    v = [_datasource pageAtIndex:page];
    if (v) {
        [_curViews addObject:v];
    }
    
    v = [_datasource pageAtIndex:last];
    if (v) {
        [_curViews addObject:v];
    }
    
    v = [_datasource pageAtIndex:rightOffBound];
    if (self.showingPageOffRightBound && v) {
        [_curViews addObject:[_datasource pageAtIndex:rightOffBound]];
    }
}

- (NSInteger)validPageValue:(NSInteger)value
{
    if (value < 0) {
        value = _totalPages + value;
    } else if (value >= _totalPages) {
        value = value - _totalPages;
    }
    
    if (value < 0) {
        value = 0;
    } else if (value > (_totalPages - 1)) {
        value = _totalPages - 1;
    }
    
    return value;
}

- (void)setViewContent:(UIView *)view atIndex:(NSInteger)index
{
    if (index == _curPage) {
        [_curViews replaceObjectAtIndex:1 withObject:view];
        for (int i = 0; i < [_curViews count]; i++) {
            UIView *v = [_curViews objectAtIndex:i];
            v.frame = CGRectOffset(v.frame, v.frame.size.width * i, 0);
            [_scrollView addSubview:v];
        }
    }
}

- (void)startAutoSwitchTimer
{
    if (self.autoSwitchPageDuration != 0.f && ![self.autoSwitchTimer isValid] && self.window && _totalPages > 0) {
        self.autoSwitchTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoSwitchPageDuration target:self selector:@selector(autoSwitch) userInfo:nil repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:self.autoSwitchTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)autoSwitch
{
    if (!self.isScrolling && !self.scrollView.isTracking && !self.scrollView.decelerating && self.superview) {
        [self.scrollView setContentOffset:CGPointMake(2 * _scrollView.frame.size.width, 0) animated:YES];
    }
}

- (void)didMoveToWindow
{
    if (self.window) {
        [self startAutoSwitchTimer];
    } else {
        [self.autoSwitchTimer invalidate];
    }
}

- (void)startCycleScrolling
{
    [self startAutoSwitchTimer];
}

- (void)stopCycleSCrolling
{
    if (self.autoSwitchTimer && [self.autoSwitchTimer isValid]) {
        [self.autoSwitchTimer invalidate];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(cycleScrollViewWillBeginDragging:)]) {
        [self.delegate cycleScrollViewWillBeginDragging:self];
    }
    [self.autoSwitchTimer invalidate];
    self.isScrolling = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    if (_totalPages) {
        CGFloat x = aScrollView.contentOffset.x;
        
        //往下翻一张
        if (x >= (2 * self.frame.size.width)){
            _curPage = [self validPageValue:_curPage + 1];
            [self loadData];
        }
        
        //往上翻
        if (x <= 0.f) {
            _curPage = [self validPageValue:_curPage - 1];
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:NO];

    if ([self.delegate respondsToSelector:@selector(cycleScrollViewDidEndDecelerating:)]) {
        [self.delegate cycleScrollViewDidEndDecelerating:self];
    }
    
    if (self.isScrolling) {
        [self startAutoSwitchTimer];
    }
    
    self.isScrolling = NO;
}

#pragma mark - Accessors

- (void)setAutoSwitchPageDuration:(NSTimeInterval)autoSwitchPageDuration
{
    _autoSwitchPageDuration = autoSwitchPageDuration;
    if (autoSwitchPageDuration == 0.f) {
        [self.autoSwitchTimer invalidate];
    } else {
        [self startAutoSwitchTimer];
    }
}

@end