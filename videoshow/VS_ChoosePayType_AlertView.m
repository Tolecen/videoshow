//
//  VS_ChoosePayType_AlertView.m
//  videoshow
//
//  Created by gutou on 2017/3/29.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "VS_ChoosePayType_AlertView.h"

@interface VS_ChoosePayType_AlertView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) UITableView *selectTableView;

@end

@implementation VS_ChoosePayType_AlertView

- (instancetype) initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        
        self.alpha = 0;
        self.backgroundColor = [AppAppearance sharedAppearance].alertBackgroundColor;
        
        [self addSubview:self.backgroundImageView];
        [self.backgroundImageView addSubview:self.selectTableView];
        [self.backgroundImageView addSubview:self.titleLab];
        self.titles = [NSArray arrayWithObjects:@"微信支付",@"支付宝支付", nil];
        self.images = [NSArray arrayWithObjects:[UIImage imageNamed:@"weixin"],[UIImage imageNamed:@"alipay"], nil];
    }
    return self;
}

- (UIImageView *) backgroundImageView
{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.image = [UIImage imageNamed:@"alert_background_2"];
        _backgroundImageView.userInteractionEnabled = YES;
        _backgroundImageView.backgroundColor = [UIColor clearColor];
        [_backgroundImageView sizeToFit];
        _backgroundImageView.center = CGPointMake(MainScreenSize.width/2, MainScreenSize.height/2);
    }
    return _backgroundImageView;
}

- (UILabel *) titleLab
{
    if (!_titleLab) {
        _titleLab = [UILabel new];
        _titleLab.text = @"本模板0元";
        _titleLab.frame = CGRectMake(0, self.backgroundImageView.height/4, self.backgroundImageView.width, self.backgroundImageView.height/4);
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.font = [UIFont systemFontOfSize:12];
    }
    return _titleLab;
}

- (UITableView *) selectTableView
{
    if (!_selectTableView) {
        _selectTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.backgroundImageView.height/2, self.backgroundImageView.width, self.backgroundImageView.height/4*2) style:UITableViewStylePlain];
        _selectTableView.scrollEnabled = NO;
        _selectTableView.rowHeight = self.backgroundImageView.height/4;
        _selectTableView.delegate = self;
        _selectTableView.dataSource = self;
    }
    return _selectTableView;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    
    UILabel *accLab = [UILabel new];
    accLab.frame = CGRectMake(0, 0, 15, 15);
    accLab.layer.borderColor = UIColorFromRGB(0x929292).CGColor;
    accLab.layer.borderWidth = 0.5;
    accLab.layer.cornerRadius = 7.5;
    cell.accessoryView = accLab;
    
    cell.imageView.image = self.images[indexPath.row];
    cell.textLabel.text = self.titles[indexPath.row];;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessView_selected"]];
    
    if (self.choosePayTypeBlock) {
        self.choosePayTypeBlock(indexPath.row);
        [self hide];
    }
}

- (void) setTitleLabText:(NSString *)titles
{
    self.titleLab.text = titles;
}

- (void) show;
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        
        self.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void) hide;
{
    [UIView animateWithDuration:0.3 animations:^{
        
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [touches.allObjects.lastObject locationInView:self.superview];
    
    //如果触摸点不在中间，消失
    if (!CGRectContainsPoint(self.backgroundImageView.frame, point)) {
        [self hide];
    }
}

@end




