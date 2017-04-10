//
//  lz_VideoDetailViewController.m
//  videoshow
//
//  Created by gutou on 2017/3/6.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "lz_VideoDetailViewController.h"
#import "lz_UseVideoViewController.h"
#import "LZ_PlayerViewController.h"
#import "BaseShareViewController.h"
#import "lz_PayOnline_ViewController.h"
#import "LZ_BasePlayerViewController.h"

#import "lz_VideoTemplateModel.h"

#import "UIButton+WebCache.h"

#import "VS_Choose_AlertView.h"
#import "VS_ChoosePayType_AlertView.h"

@interface lz_VideoDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *left_3_lab;
@property (weak, nonatomic) IBOutlet UILabel *left_4_lab;
@property (weak, nonatomic) IBOutlet UIImageView *left_4_imageview;


@property (weak, nonatomic) IBOutlet UIButton *videoImageView;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *sizeLab;
@property (weak, nonatomic) IBOutlet UILabel *heatLab;
@property (weak, nonatomic) IBOutlet UILabel *priceLab;
@property (weak, nonatomic) IBOutlet UIButton *useBtn;
@property (weak, nonatomic) IBOutlet UIButton *colectBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *downBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;

@property (weak, nonatomic) IBOutlet UIButton *shareBtn_background;
@property (nonatomic, strong) __block lz_VideoTemplateModel *dataModel;

@property (nonatomic, copy) NSString *current_Template_id;

@end

@implementation lz_VideoDetailViewController

- (void) showBackItemAction:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) showDeleteItemAction:(UIButton *)button
{
    NSLog(@"删除模板");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"视频模板";
    [self showBackItem];
    
    self.dataModel = [lz_VideoTemplateModel new];
    self.current_Template_id = [NSString string];
    
    lz_VideoTemplateModel *model = [self.dict valueForKey:@"model"];
    self.current_Template_id = model.template_id;
    
    [self requestData];
}

- (void) requestData
{
    WeakTypeof(weakSelf)
    
    if (self.MyController_Type == MyController_UseTemplate) {
        
        [self HudShowWithStatus:@"正在加载"];
        [lz_VideoTemplateModel requestTemplateDetailWithTemplateID:[NSNumber numberWithInteger:[self.current_Template_id integerValue]] SuccessHandle:^(id responseObject) {
            
            weakSelf.dataModel = responseObject;
            [weakSelf setupViewWithData:responseObject];
            
            [self HudHide];
        } FailureHandle:^(NSError *error) {
            
        }];
        
    }else if (self.MyController_Type == MyController_ShareTemplate) {
        
        [self HudShowWithStatus:@"正在加载"];
        [lz_VideoTemplateModel requestMyWorkDetailWithTemplate_id:self.current_Template_id
                                                         isDetail:YES
                                                    SuccessHandle:^(id responseObject) {
                                                        
                                                        weakSelf.dataModel = responseObject;
                                                        [weakSelf setupViewWithData:responseObject];
                                                        
                                                    } FailureHandle:^(NSError *error) {
                                                        
                                                    }];
        
    }else {}
}

- (void) setupViewWithData:(lz_VideoTemplateModel *)model
{
    if (self.MyController_Type == MyController_UseTemplate) {
        
        self.useBtn.hidden = NO;
        self.colectBtn.hidden = NO;
        self.editBtn.hidden = YES;
        self.downBtn.hidden = YES;
        self.shareBtn.hidden = YES;
        
        
        if (model.template_image) {
            [self.videoImageView setBackgroundImage:model.template_image forState:UIControlStateNormal];
        }else {
            [self.videoImageView sd_setBackgroundImageWithURL:[NSURL URLWithString:model.template_picture] forState:UIControlStateNormal];
        }
        self.videoTitleLab.text = model.template_name;
        self.timeLab.text = model.template_time_long;
        self.sizeLab.text = model.template_size;
        self.heatLab.text = model.template_render_count;
        if ([model.charge_money integerValue] == 0) {
            self.priceLab.text = @"免费";
        }else {
            self.priceLab.text = model.charge_money;
        }
    }else if (self.MyController_Type == MyController_ShareTemplate) {
        
        [self showDeleteItem];
        
        self.useBtn.hidden = YES;
        self.colectBtn.hidden = YES;
        self.shareBtn_background.hidden = YES;
        self.editBtn.hidden = NO;
        self.downBtn.hidden = NO;
        self.shareBtn.hidden = NO;
        
        [self.editBtn sizeToFit];
        [self.downBtn sizeToFit];
        [self.shareBtn sizeToFit];
        

        self.left_3_lab.text = @"状态：";
        self.left_3_lab.textAlignment = NSTextAlignmentCenter;
        self.left_4_lab.hidden = YES;
        self.left_4_imageview.hidden = YES;
        
        CGFloat btnW = MainScreenSize.width/5;
        CGFloat x = (MainScreenSize.width - btnW*3)/6;
        
        
        self.editBtn.frame = CGRectMake(x, self.colectBtn.center.y-10, btnW, btnW);
        UILabel *btn_title_lab_edit = [self create_Btn_Title_Lab];
        btn_title_lab_edit.frame = CGRectMake(0, self.editBtn.height, self.editBtn.width, 20);
        btn_title_lab_edit.text = @"编辑";
        [self.editBtn addSubview:btn_title_lab_edit];
        
        
        self.downBtn.frame = CGRectMake(self.editBtn.right+2*x, self.editBtn.origin.y, btnW, btnW);
        UILabel *btn_title_lab_down = [self create_Btn_Title_Lab];
        btn_title_lab_down.frame = btn_title_lab_edit.frame;
        btn_title_lab_down.text = @"下载";
        [self.downBtn addSubview:btn_title_lab_down];
        
        
        self.shareBtn.frame = CGRectMake(self.downBtn.right+2*x, self.editBtn.origin.y, btnW, btnW);
        UILabel *btn_title_lab_share = [self create_Btn_Title_Lab];
        btn_title_lab_share.frame = btn_title_lab_edit.frame;
        btn_title_lab_share.text = @"分享";
        [self.shareBtn addSubview:btn_title_lab_share];
        
        
        [self.videoImageView sd_setBackgroundImageWithURL:[NSURL URLWithString:model.work_picture] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_serve_image"]];
        self.videoTitleLab.text = model.work_name;
        self.timeLab.text = model.work_time_long;
        self.sizeLab.text = model.work_size;
        if (model.make_status.integerValue == 0) {
            self.heatLab.text = @"待处理";
        }else if (model.make_status.integerValue == 1) {
            self.heatLab.text = @"合成中";
        }else if (model.make_status.integerValue == 2) {
            self.heatLab.text = @"失败";
        }else if (model.make_status.integerValue == 3) {
            self.heatLab.text = @"成功合成";
        }else {
            self.heatLab.text = model.make_status;
        }
        
        self.priceLab.hidden = YES;
        
    }else {}
}

- (UILabel *) create_Btn_Title_Lab
{
    UILabel *btn_title_lab = [UILabel new];
    btn_title_lab.textAlignment = NSTextAlignmentCenter;
    [btn_title_lab sizeToFit];
    return btn_title_lab;
}

- (IBAction)videoBtnPlayAction:(UIButton *)sender
{
//    NSLog(@"视频播放");
    LZ_BasePlayerViewController *vc = [[LZ_BasePlayerViewController alloc] init];
    
    
    if (self.MyController_Type == MyController_UseTemplate) {
        
        vc.playerUrl = self.dataModel.template_preview_url;
        
    }else if (self.MyController_Type == MyController_ShareTemplate) {
        
        vc.playerUrl = self.dataModel.download_url;
        
    }else {};
    
    [self.navigationController presentViewController:vc animated:YES completion:NULL];
}
- (IBAction)useBtnAction:(UIButton *)sender
{
    if (![AppDataManager defaultManager].hasLogin) {
        
        [self showLoginViewControllerWithCurrentViewController:self];
        
        [self HudShowWithStatus:@"请登录" Delay:1.5];
        return;
    }
//    NSLog(@"使用模板");
    lz_UseVideoViewController *vc = [[lz_UseVideoViewController alloc] init];
    vc.datas = self.dataModel.combine_resources;
    vc.template_id = [NSNumber numberWithInteger:[self.dataModel.template_id integerValue]];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)colectBtnAction:(UIButton *)sender
{
    if (![AppDataManager defaultManager].hasLogin) {
        
        [self showLoginViewControllerWithCurrentViewController:self];
        
        [self HudShowWithStatus:@"请登录" Delay:1.5];
        return;
    }

//    NSLog(@"收藏模板");
    [lz_VideoTemplateModel requestCollectionDetailWithTemplate_id:self.current_Template_id
                                                     isCollection:[self.dataModel.has_collected boolValue]
                                                    SuccessHandle:^(id responseObject) {
                                                        
                                                        [self HudShowWithStatus:responseObject];
                                                    } FailureHandle:^(NSError *error) {
                                                        
                                                    }];
}
- (IBAction)editBtnAction:(UIButton *)sender
{
    NSLog(@"编辑模板");
}
- (IBAction)downBtnAction:(UIButton *)sender
{
    //非会员
    if (![AppDataManager defaultManager].hasVip) {
        
        //是否付费
        if ([self isFree_Template]) {//免费
            
            //弹出水印选项弹窗
            VS_Choose_AlertView *vc = [[VS_Choose_AlertView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            [vc setTitles:@[@"去水印",@"不去水印"]];
            vc.block = ^(WaterMarkType WaterMarkType){
                
                if (WaterMarkType == WaterMarkType_TextWaterMark) {//如果去水印
                    
                    //弹出支付选项
                    [self showPayAlertViewWithMoney:nil actionHandle:^(NSInteger index_type) {
                        [self HudShowWithStatus:@"非会员-免费模板-去水印-充值成功-执行下载"];
                        NSLog(@"非会员-免费模板-去水印-充值成功-执行下载");
                        if (index_type == 0) {
                            
                        }else if (index_type == 1) {
                            
                        }else{}
                    }];
                }else if (WaterMarkType == WaterMarkType_PicWaterMark) {//不去水印
                    
                    [self HudShowWithStatus:@"非会员-免费模板-不去水印-执行下载"];
                    NSLog(@"非会员-免费模板-不去水印-执行下载");
                }else{}
            };
            [vc show];
            
        }else {//付费
            
            //购买模板
            [self showPayAlertViewWithMoney:self.dataModel.charge_money actionHandle:^(NSInteger index_type) {
                [self HudShowWithStatus:@"非会员-付费模板-购买模板-执行下载"];
                NSLog(@"非会员-付费模板-购买模板-执行下载");
                if (index_type == 0) {
                    
                }else if (index_type == 1) {
                    
                }else{}
            }];
        }
    }else {
        //会员
        if ([self isFree_Template]) {//免费
            [self HudShowWithStatus:@"会员-免费模板-执行下载"];
            NSLog(@"会员-免费模板-执行下载");
        }else {//付费
            [self HudShowWithStatus:@"会员-付费模板-购买模板-执行下载"];
            NSLog(@"会员-付费模板-购买模板-执行下载");
        }
    }
}
- (IBAction)shareBtn_backgroundAction:(id)sender
{
    [self shareBtnAction:nil];
}
- (IBAction)shareBtnAction:(UIButton *)sender
{
    NSLog(@"分享模板");
    //非会员
    if (![AppDataManager defaultManager].hasVip) {
        
        //是否付费
        if ([self isFree_Template]) {//免费
            
            //弹出水印选项弹窗
            VS_Choose_AlertView *vc = [[VS_Choose_AlertView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            [vc setTitles:@[@"去水印",@"不去水印"]];
            vc.block = ^(WaterMarkType WaterMarkType){
                
                if (WaterMarkType == WaterMarkType_TextWaterMark) {//如果去水印
                    
                    //弹出支付选项
                    [self showPayAlertViewWithMoney:nil actionHandle:^(NSInteger index_type) {
                        [self HudShowWithStatus:@"非会员-免费模板-去水印-充值成功-执行分享"];
                        NSLog(@"非会员-免费模板-去水印-充值成功-执行分享");
                        [self showShareView];
                        if (index_type == 0) {
                            
                        }else if (index_type == 1) {
                            
                        }else{}
                    }];
                }else if (WaterMarkType == WaterMarkType_PicWaterMark) {//不去水印
                    
                    [self HudShowWithStatus:@"非会员-免费模板-不去水印-执行分享"];
                    NSLog(@"非会员-免费模板-不去水印-执行分享");
                    [self showShareView];
                }else{}
            };
            [vc show];
            
        }else {//付费
            
            //购买模板
            [self showPayAlertViewWithMoney:self.dataModel.charge_money actionHandle:^(NSInteger index_type) {
                [self HudShowWithStatus:@"非会员-付费模板-购买模板-执行分享"];
                NSLog(@"非会员-付费模板-购买模板-执行分享");
                [self showShareView];
                if (index_type == 0) {
                    
                }else if (index_type == 1) {
                    
                }else{}
            }];
        }
    }else {
        //会员
        if ([self isFree_Template]) {//免费
            [self HudShowWithStatus:@"会员-免费模板-执行分享"];
            NSLog(@"会员-免费模板-执行分享");
            [self showShareView];
        }else {//付费
            [self HudShowWithStatus:@"会员-付费模板-购买模板-执行分享"];
            NSLog(@"会员-付费模板-购买模板-执行分享");
            [self showShareView];
        }
    }
}

- (void) showShareView
{
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
}

- (void) showPayAlertViewWithMoney:(NSString *)money actionHandle:(void (^)(NSInteger index_type))handle
{
    VS_ChoosePayType_AlertView *view = [[VS_ChoosePayType_AlertView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    if (money) {
        [view setTitleLabText:[NSString stringWithFormat:@"本模板%@元",money]];
    }

    view.choosePayTypeBlock = ^(NSInteger index_type) {
        
//        NSLog(@"index = %ld",index_type);
        handle(index_type);
    };
    [view show];
}

//是否是免费模板
- (BOOL) isFree_Template
{
    return ![self.dataModel.is_charge boolValue];
}

@end
