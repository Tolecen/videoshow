 

#import "XLScrollView.h"
#import "TAPageControl.h"
#import "UIImage+ImageFromColor.h"

@interface XLScrollView () <UIScrollViewDelegate>

@property (nonatomic , assign  ) NSInteger      totalPageCount;
@property (nonatomic , strong  ) NSMutableArray *contentViews;
@property (nonatomic , strong  ) UIScrollView   *scrollView;
@property (nonatomic , strong  ) NSTimer        *animationTimer;
@property (nonatomic , strong  ) TAPageControl  * pageControl;
@property (nonatomic , strong  ) UILabel        *label;
@property (nonatomic , assign  ) BOOL           animation;

@end


@implementation XLScrollView

-(void)dealloc
{

}

- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration
{
    self = [self initWithFrame:frame];
    if(animationDuration >0){
        _animationDuration = animationDuration;
        _animation = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addSubview:self.scrollView];
//        [self descripitionView];
        [self addSubview:self.pageControl];
    }
    return self;
}

-(void)setAnimationDuration:(NSTimeInterval)animationDuration
{
    _animationDuration = animationDuration;
    _animation = YES;
}

-(UIScrollView *)scrollView
{
    if(!_scrollView){
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _scrollView.delegate = self;
        _scrollView.contentOffset = CGPointMake(CGRectGetWidth(_scrollView.frame), 0);
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.directionalLockEnabled = YES;
        _scrollView.bounces = NO;
    }
    
    return _scrollView;
}

-(TAPageControl *)pageControl
{
    if(!_pageControl)
    {
        TAPageControl *pageControl = [[TAPageControl alloc] init];
        pageControl.center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds) - 10);
        pageControl.numberOfPages = [_delegate totalPagesCountInXlScrollView:self];
        pageControl.dotImage = [UIImage buildImageWithColor:[UIColor whiteColor] forSize:CGSizeMake(19, 2.5)];
        pageControl.currentDotImage = [AppTool createImageFromColor:UIColorFromRGB(0x929292) withRect:CGRectMake(0, 0, 100, 5)];
//      pageControl.currentDotImage = [UIImage imageNamed:@"currentDot_image"];
        pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        pageControl.currentPage = 0;
        [self addSubview:pageControl];
        _pageControl = pageControl;
    }
    
    return _pageControl;
}


-(void)descripitionView
{
    if(!_label){
        UIView * _descripitionView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 60, CGRectGetWidth(self.bounds), 40)];
        _descripitionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleRightMargin;
        _descripitionView.userInteractionEnabled = NO;
        CAGradientLayer* layer = [CAGradientLayer layer];
        layer.frame = _descripitionView.bounds;
        layer.startPoint = CGPointMake(.5, 1);
        layer.endPoint = CGPointMake(.5, 0);
        layer.colors = @[(__bridge id)[UIColor colorWithWhite:0.000 alpha:0.500].CGColor,
                         (__bridge id)[UIColor clearColor].CGColor];
        [_descripitionView.layer addSublayer:layer];
        
        [self addSubview:_descripitionView];
        [self bringSubviewToFront:_descripitionView];

        _label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, _descripitionView.frame.size.width - 20, _descripitionView.frame.size.height-10)];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont systemFontOfSize:14];
        _label.textAlignment = NSTextAlignmentLeft;
//        _label.text = [self labelText:_currentPageIndex];
        [_descripitionView  addSubview:_label];
    }
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    switch (_totalPageCount) {
        case 1:
        {
            [_scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
        }
            break;
        case 2:
        {
            [_scrollView setContentSize:CGSizeMake(3 * CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
        }
            break;
            
        default:
            [_scrollView setContentSize:CGSizeMake(_totalPageCount * CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
            break;
    }
//    [self layoutContentViews];
}

- (void)setTotalPagesCount
{
//    _label.text = [self labelText:_currentPageIndex];
    _pageControl.numberOfPages = _totalPageCount;
    _currentPageIndex = 0;
    switch (_totalPageCount) {
        case 1:
        {
            [_scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
        }
            break;
        case 2:
        {
            [_scrollView setContentSize:CGSizeMake(3 * CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
        }
            break;
            
        default:
            [_scrollView setContentSize:CGSizeMake(_totalPageCount * CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
            break;
    }
    [self configContentViews];
    if(_animation){
        [self starTimer];
    }
}


-(void)starTimer
{
    [self stopTimer];
    if (_animationTimer) {
        [_animationTimer fire];
    }else{
        _animationTimer = [NSTimer scheduledTimerWithTimeInterval:_animationDuration target:self selector:@selector(animationTimerDidFired:) userInfo:nil repeats:YES];
    }
}

-(void)stopTimer
{
    [_animationTimer invalidate];
    _animationTimer = nil;
}

-(void)updateOfInterface
{
    [self stopTimer];
    if([self totalPageCount] > 0){
        [self setTotalPagesCount];
    }
}

#pragma mark -
#pragma mark - 私有函数

- (void)configContentViews
{
    if([self totalPageCount] >0){
        [_contentViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self setScrollViewContentDataSource];
        [self addSubviews];
    }
}

-(void)addSubviews {
    [_contentViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIImageView* contentView = obj;
        contentView.contentMode = UIViewContentModeScaleAspectFill;
        contentView.userInteractionEnabled = YES;
        contentView.clipsToBounds = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewTapAction:)];
        [contentView addGestureRecognizer:tapGesture];
        [self layoutContentView:contentView atIndex:idx];
        [_scrollView addSubview:contentView];
        
    }];
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
}

-(void)layoutContentViews {
    [_contentViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIImageView* contentView = obj;
        [self layoutContentView:contentView atIndex:idx];
    }];
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
}

-(void)layoutContentView:(UIView*)contentView atIndex:(NSUInteger)index {
    
    CGRect rightRect = contentView.frame;
    rightRect.size = CGSizeMake(_scrollView.bounds.size.width, _scrollView.bounds.size.height);
    rightRect.origin = CGPointMake(CGRectGetWidth(_scrollView.bounds) * index, 0);
    contentView.frame = rightRect;
}


/**
 *  设置scrollView的content数据源，即contentViews
 */
- (void)setScrollViewContentDataSource
{
    NSInteger previousPageIndex = [self getValidNextPageIndexWithPageIndex:_currentPageIndex - 1];
    NSInteger rearPageIndex = [self getValidNextPageIndexWithPageIndex:_currentPageIndex + 1];
    if (_contentViews == nil) {
        _contentViews = [@[] mutableCopy];
    }
    [_contentViews removeAllObjects];
    
    if ([_delegate respondsToSelector:@selector(XLscrollView:imageAtIndex:)]) {
        [_contentViews addObject:[self imageView:(previousPageIndex)]];
        [_contentViews addObject:[self imageView:(_currentPageIndex)]];
        [_contentViews addObject:[self imageView:(rearPageIndex)]];
    }
}

- (NSInteger)getValidNextPageIndexWithPageIndex:(NSInteger)currentPageIndex;
{
    if(currentPageIndex == -1) {
        return _totalPageCount - 1;
    } else if (currentPageIndex == _totalPageCount) {
        return 0;
    } else {
        return currentPageIndex;
    }
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self starTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int contentOffsetX = scrollView.contentOffset.x;
    if(contentOffsetX >= (2 * CGRectGetWidth(scrollView.frame))) {
        
        _currentPageIndex = [self getValidNextPageIndexWithPageIndex:_currentPageIndex + 1];
//               NSLog(@"next，当前页:%d",_currentPageIndex);
        [self configContentViews];
        
    }
    if(contentOffsetX <= 0) {
        _currentPageIndex = [self getValidNextPageIndexWithPageIndex:_currentPageIndex - 1];
//         NSLog(@"next，当前页:%d",_currentPageIndex);
        [self configContentViews];
        
    }
    _pageControl.currentPage = _currentPageIndex;
    _label.text = [self labelText:_currentPageIndex];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0) animated:YES];
}

#pragma mark -
#pragma mark - 响应事件

- (void)animationTimerDidFired:(NSTimer *)timer
{
    if (_totalPageCount < 2) {
        return;
    }
    CGPoint newOffset = CGPointMake(_scrollView.contentOffset.x + CGRectGetWidth(_scrollView.bounds), _scrollView.contentOffset.y);
    [_scrollView setContentOffset:newOffset animated:YES];
}

- (void)contentViewTapAction:(UITapGestureRecognizer *)tap
{
    if (_currentPageIndex >= _totalPageCount || _currentPageIndex < 0) {
        return;
    }
    
    if([_delegate respondsToSelector:@selector(XLscrollView:contentViewTapAction:)])
    {
        [_delegate XLscrollView:self contentViewTapAction:_currentPageIndex];
    }
}


-(NSString *)labelText:(NSInteger)index
{
    if(index < 0){
        return nil;
    }
    if([_delegate respondsToSelector:@selector(XLscrollView:labelTextAtIndex:)])
    {
        return [_delegate XLscrollView:self labelTextAtIndex:index];
    }
    
    return nil;
}

-(NSInteger)totalPageCount
{
    if([_delegate respondsToSelector:@selector(totalPagesCountInXlScrollView:)])
    {
        _totalPageCount = [_delegate totalPagesCountInXlScrollView:self];
    }
    return _totalPageCount;
}

-(UIView *)imageView:(NSInteger)index
{
    if([_delegate respondsToSelector:@selector(XLscrollView:imageAtIndex:)])
    {
        return [_delegate XLscrollView:self imageAtIndex: index];
    }
    return nil;
}


@end
