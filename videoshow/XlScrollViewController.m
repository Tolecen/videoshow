 

#import "XlScrollViewController.h"
#import "BannerModel.h"

#import "UIImageView+AFNetworking.h"

@interface XlScrollViewController ()<XLScrollViewDelegate>

@property (nonatomic,strong)XLScrollView *xlScrollView;
@property (nonatomic,strong)NSArray *dataArray;

@property (nonatomic, strong) UIImageView *defaultImageView;

@end

@implementation XlScrollViewController

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(starTimer)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopTimer)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    [_xlScrollView starTimer];
}

-(void)setAnimationDuration:(CGFloat)animationDuration
{
    _xlScrollView.animationDuration = animationDuration;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    _xlScrollView = [[XLScrollView alloc] initWithFrame:self.view.bounds];
    _xlScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _xlScrollView.currentPageIndex = _pageNumber;
    _xlScrollView.delegate = self;

    [self.view addSubview:_xlScrollView];
    
    
    _defaultImageView = [[UIImageView alloc]initWithFrame:_xlScrollView.bounds];
    _defaultImageView.contentMode = UIViewContentModeScaleAspectFill;
     _defaultImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _defaultImageView.layer.masksToBounds = YES;
    _defaultImageView.image = [AppAppearance sharedAppearance].defaultImage;
    [self.view addSubview:_defaultImageView];
    [self.view sendSubviewToBack:_defaultImageView];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeNotificationCenter];
    [_xlScrollView stopTimer];
}

-(void)removeNotificationCenter
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)updateOfInterface:(id)model;
{
    //[UIImageView clearCache];
    NSArray *arry = model;
    if(arry.count >0){
        _defaultImageView.hidden = YES;
        _dataArray = arry;
        [_xlScrollView updateOfInterface];
    }else{
        _defaultImageView.hidden = NO;
    }
}
-(void)starTimer
{
    if(_dataArray.count >0){
        [_xlScrollView starTimer];
    }
}

-(void)stopTimer
{
    [_xlScrollView stopTimer];
}

#pragma mark - XlScrollViewControllerDelegate

-(NSInteger)totalPagesCountInXlScrollView:(XLScrollView *)scrollView
{
    return _dataArray.count;
}

-(UIView *)XLscrollView:(XLScrollView *)scrollView imageAtIndex:(NSInteger)pageIndex
{
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _xlScrollView.frame.size.width,_xlScrollView.frame.size.height)];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    BannerModel *bannerModel = [_dataArray objectAtIndex:pageIndex];
    
    [imageView setImageWithURL:[NSURL URLWithString:bannerModel.image_url] placeholderImage:[AppAppearance sharedAppearance].defaultImage];
    
    return imageView;
}

-(NSString *)XLscrollView:(XLScrollView *)scrollView labelTextAtIndex:(NSInteger)pageIndex
{
    return nil;
}

-(void)XLscrollView:(XLScrollView *)scrollView contentViewTapAction:(NSInteger)pageIndex
{
    //这个方法为了把点击跳转放到首页中  可以改变首页的一些设置
    if ([self.delegate respondsToSelector:@selector(XLscrollView:contentViewTapAction:Model:)]) {
        [self.delegate XLscrollView:scrollView contentViewTapAction:pageIndex Model:(BannerModel *)_dataArray[pageIndex]];
    }
    return;
}

@end
