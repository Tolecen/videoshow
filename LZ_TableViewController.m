//
//  LZ_TableViewController.m
//  AVFoundation_Test
//
//  Created by gutou on 2017/3/12.
//  Copyright © 2017年 gutou. All rights reserved.
//

#import "LZ_TableViewController.h"
#import "LZ_TestTableViewCell.h"
#import "LZ_PlayerViewController.h"
#import "AppDelegate.h"
#import "VS_Choose_AlertView.h"
#import "BaseShareViewController.h"
#import "LZ_BasePlayerViewController.h"

#import "UIView+WebVideoCache.h"
#import "JPVideoPlayerCache.h"
#import "UITableView+VideoPlay.h"

#define Cell_Height ([UIScreen mainScreen].bounds.size.height/3)

@interface LZ_TableViewController ()<UIScrollViewDelegate>


/**
 * For calculate the scroll derection of tableview, we need record the offset-Y of tableview when begain drag.
 * 刚开始拖拽时scrollView的偏移量Y值, 用来判断滚动方向.
 */
@property(nonatomic, assign)CGFloat offsetY_last;

@property (nonatomic, strong) NSArray *videoDataArr;//存储cell数据

@end

@implementation LZ_TableViewController

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.tableView.playingCell) {
        [self.tableView.playingCell.videoImv stopPlay];
    }
}

- (void) allPause
{
    if (self.tableView.playingCell) {
        [self.tableView.playingCell.videoImv stopPlay];
    }
}

- (void) allPlay
{
    if (!self.tableView.playingCell) {
        
        // Find the first cell need to play video in visiable cells.
        // 在可见cell中找第一个有视频的进行播放.
        [self.tableView playVideoInVisiableCells];
    }
    else{
        
        NSURL *url = [NSURL URLWithString:self.tableView.playingCell.videoPath];
        [self.tableView.playingCell.videoImv jp_playVideoMutedDisplayStatusViewWithURL:url];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.tableView.playingCell) {
        
        // Find the first cell need to play video in visiable cells.
        // 在可见cell中找第一个有视频的进行播放.
        [self.tableView playVideoInVisiableCells];
    }
    else{
        
        NSURL *url = [NSURL URLWithString:self.tableView.playingCell.videoPath];
        [self.tableView.playingCell.videoImv jp_playVideoMutedDisplayStatusViewWithURL:url];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.videoDataArr = [NSArray array];
    self.videoDataArr = @[TestPlayer_Url_1,TestPlayer_Url_1,TestPlayer_Url_1,TestPlayer_Url_1,TestPlayer_Url_1,TestPlayer_Url_1,];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videoDataArr.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [LZ_TestTableViewCell cellHeightWithData:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    LZ_TestTableViewCell *cell = [LZ_TestTableViewCell cellWithTableView:tableView reuseIdentifier:nil indexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.videoPath = self.videoDataArr[indexPath.row];
    cell.indexPath = indexPath;
//    cell.model = @[TestPlayer_Url_1];
    
    if (self.tableView.maxNumCannotPlayVideoCells > 0) {
        if (indexPath.row <= self.tableView.maxNumCannotPlayVideoCells-1) { // 上不可及
            cell.cellStyle = JPPlayUnreachCellStyleUp;
        }
        else if (indexPath.row >= self.videoDataArr.count-self.tableView.maxNumCannotPlayVideoCells){ // 下不可及
            cell.cellStyle = JPPlayUnreachCellStyleDown;
        }
        else{
            cell.cellStyle = JPPlayUnreachCellStyleNone;
        }
    }
    else{
        cell.cellStyle = JPPlayUnreachCellStyleNone;
    }
    
    cell.PlayCellBlock = ^(NSInteger index) {
      
        if (index == 0) {
            
            //下载
            
        }else if (index == 1) {
            
            //分享
            NSString *shareTitle             = @"小视秀 xxx";
            
            NSString *shareText              = @"点我进入小视秀";
            
            NSString *shareUrl               = @"url";
            
            //创建分享消息对象
            UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
            
            //创建网页内容对象
            //    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:@"分享标题" descr:@"分享内容描述" thumImage:[UIImage imageNamed:@"icon"]];
            NSString* thumbURL =  @"http://m.ayilaile.com/ayapp/ad/1/img/img_logo.png";
            
            UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:shareTitle descr:shareText thumImage:thumbURL];
            //设置网页地址
            shareObject.webpageUrl = shareUrl;
            
            //分享消息对象设置分享内容对象
            messageObject.shareObject = shareObject;
            
            BaseShareViewController *vc = [[BaseShareViewController alloc] init];
            vc.messageObject = messageObject;
            
            [vc showWithViewController:self];
            
        }else if (index == 2) {
            
            VS_Choose_AlertView *view = [[VS_Choose_AlertView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            view.block = ^ (WaterMarkType type){
              
                //跳转文字水印
                if (type == WaterMarkType_TextWaterMark) {
                    self.lz_OnlineVideoBlock(0);
                }else if (type == WaterMarkType_PicWaterMark) {//跳转图片水印
                    self.lz_OnlineVideoBlock(1);
                }else {
                    
                }
            };
            [view show];
            
        }else {
            LZ_BasePlayerViewController *vc = [[LZ_BasePlayerViewController alloc] init];
            vc.playerUrl = self.videoDataArr[indexPath.row];
            [self allPause];
            [self.navigationController presentViewController:vc animated:YES completion:NULL];
        }
    };
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    LZ_TestTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (decelerate == NO)
    // scrollView已经完全静止
    [self.tableView handleScrollStop];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // scrollView已经完全静止
    [self.tableView handleScrollStop];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 处理滚动方向
    [self handleScrollDerectionWithOffset:scrollView.contentOffset.y];
    
    // Handle cyclic utilization
    // 处理循环利用
    [self.tableView handleQuickScroll];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.offsetY_last = scrollView.contentOffset.y;
}

-(void)handleScrollDerectionWithOffset:(CGFloat)offsetY{
    self.tableView.currentDerection = (offsetY-self.offsetY_last>0) ? JPVideoPlayerDemoScrollDerectionUp : JPVideoPlayerDemoScrollDerectionDown;
    self.offsetY_last = offsetY;
}

- (void) requestRefresh
{
    [self finishRequest];
}

- (void) requestGetMore
{
    [self finishRequest];
}

@end
