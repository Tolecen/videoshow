 

#import "BaseViewController.h"
#import "XLScrollView.h"

@protocol XLScrollViewDelegate2 <NSObject>

-(void)XLscrollView:(XLScrollView *)scrollView contentViewTapAction:(NSInteger)pageIndex Model:(id)model;

@end

@interface XlScrollViewController : BaseViewController

@property (nonatomic ) CGFloat animationDuration;
@property (nonatomic ) NSInteger pageNumber;
-(void)updateOfInterface:(id)model;

@property (nonatomic, weak) id<XLScrollViewDelegate2> delegate;

@end
