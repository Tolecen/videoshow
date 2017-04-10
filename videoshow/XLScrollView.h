 

#import <UIKit/UIKit.h>

@protocol XLScrollViewDelegate;
@interface XLScrollView : UIView
@property (nonatomic , assign) NSTimeInterval animationDuration;
@property (nonatomic , readonly) UIScrollView *scrollView;
@property (nonatomic , assign) NSInteger currentPageIndex;
@property(nonatomic,weak)id <XLScrollViewDelegate>delegate;

/**
 *  初始化
 *
 *  @param frame             frame
 *  @param animationDuration 自动滚动的间隔时长。如果<=0，不自动滚动。
 *
 *  @return instance
 */

- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration;
/**
 更新界面
 **/
-(void)updateOfInterface;

-(void)starTimer;

-(void)stopTimer;

@end


@protocol XLScrollViewDelegate <NSObject>

/**
 数据源：获取总的page个数
 **/
-(NSInteger)totalPagesCountInXlScrollView:(XLScrollView *)scrollView;
/**
 数据源：获取第pageIndex个位置的image
 **/
-(UIView *)XLscrollView:(XLScrollView *)scrollView imageAtIndex:(NSInteger)pageIndex;
/**
 数据源：获取第pageIndex个位置的LabelText **/
-(NSString *)XLscrollView:(XLScrollView *)scrollView labelTextAtIndex:(NSInteger)pageIndex;
/**
 当点击的时候
 **/
-(void)XLscrollView:(XLScrollView *)scrollView contentViewTapAction:(NSInteger)pageIndex;

@end
