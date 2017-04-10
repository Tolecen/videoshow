//
//  lz_MyWaterMarkViewController.m
//  videoshow
//
//  Created by gutou on 2017/3/8.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "lz_MyWaterMarkViewController.h"
#import "VS_BottomImageButton.h"
#import <CoreText/CoreText.h>

#import "lz_VideoTemplateModel.h"

#define HeaderViewBottom (MainScreenSize.height * 0.26)

@interface lz_MyWaterMarkViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) VS_BottomImageButton *btn_1;
@property (nonatomic, strong) VS_BottomImageButton *btn_2;

@property (nonatomic, strong) NSArray *colorsArr;//存储字体颜色
@property (nonatomic, strong) NSMutableArray *imagesArr;//存储字体颜色图片

@property (nonatomic, strong) UIView *imageSettingBackgroundView;

@property (nonatomic, strong) NSArray *pointArr;//位置arr
@property (nonatomic, strong) NSArray<NSString *> *pointNumArr;//位置point

@property (nonatomic, strong) NSArray *fonts;//存储字体库名字string
//@property (nonatomic, strong) NSMutableDictionary *fontNames;//存储字体库 uifont
@property (nonatomic, strong) NSString *errorMessage;


@property (nonatomic, strong) UITextField *updateLabel;//用于提交的文字水印效果
@property (nonatomic, strong) UIImageView *updateImageView;//用于提交的图片水印效果


@property (nonatomic, strong) UIImagePickerController *imagePickController;

@end


@implementation lz_MyWaterMarkViewController

- (UIImagePickerController *) imagePickController
{
    if (!_imagePickController) {
        _imagePickController = [[UIImagePickerController alloc] init];
        _imagePickController.delegate = self;
    }
    return _imagePickController;
}

- (UITextField *) updateLabel
{
    if (!_updateLabel) {
        _updateLabel = [[UITextField alloc] init];
        _updateLabel.textAlignment = NSTextAlignmentCenter;
        _updateLabel.frame = CGRectMake((MainScreenSize.width-100)/2, (HeaderViewBottom-40)/2, 100, 40);
        _updateLabel.placeholder = @"请输入文字水印";

        _updateLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        _updateLabel.layer.borderWidth = 1;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panUploadLabelOrImage:)];
        
        _updateLabel.userInteractionEnabled = YES;
        [_updateLabel addGestureRecognizer:pan];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUploadLabelOrImage:)];
        [_updateLabel addGestureRecognizer:tap];
        
        [self resetUpdateLabel];
    }
    return _updateLabel;
}

//重置水印label的属性
- (void) resetUpdateLabel
{
    _updateLabel.text = @"";
    _updateLabel.textColor = [UIColor whiteColor];
    _updateLabel.font = [UIFont systemFontOfSize:12];
    _updateLabel.frame = CGRectMake((MainScreenSize.width-100)/2, (HeaderViewBottom-40)/2, 100, 40);
}

//上传的图片
- (UIImageView *) updateImageView
{
    if (!_updateImageView) {
        _updateImageView = [[UIImageView alloc] init];
        _updateImageView.frame = CGRectMake((MainScreenSize.width-100)/2, (HeaderViewBottom-100)/2, 100, 100);
        _updateImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        _updateImageView.layer.borderWidth = 1;
        _updateImageView.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panUploadLabelOrImage:)];
        [_updateImageView addGestureRecognizer:pan];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUploadLabelOrImage:)];
        [_updateImageView addGestureRecognizer:tap];
        
        [self resetUpdateImageView];
        
        UIImageView *panImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"water_refresh"]];
        panImageView.frame = CGRectMake(_updateImageView.width-10, -10, 20, 20);
        panImageView.tag = 10;
        [_updateImageView addSubview:panImageView];
        UIPanGestureRecognizer *panChangeFrameGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(imageChangeBoundsWithPan:)];
        panImageView.userInteractionEnabled = YES;
        [panImageView addGestureRecognizer:panChangeFrameGes];
    }
    return _updateImageView;
}

//重置水印imageview的属性
- (void) resetUpdateImageView
{
    _updateImageView.frame = CGRectMake((MainScreenSize.width-100)/2, (HeaderViewBottom-100)/2, 100, 100);
    UIImageView *anImageView = [_updateImageView viewWithTag:10];
    anImageView.frame = CGRectMake(_updateImageView.width-10, -10, 20, 20);
}

//图片设置的view
- (UIView *) imageSettingBackgroundView
{
    if (!_imageSettingBackgroundView) {
        _imageSettingBackgroundView = [UIView new];
        _imageSettingBackgroundView.backgroundColor = [UIColor whiteColor];
        _imageSettingBackgroundView.frame = CGRectMake(0, HeaderViewBottom + 41.5, MainScreenSize.width, self.view.height - HeaderViewBottom - 41.5);
        UIView *line = [UIView new];
        line.backgroundColor = UIColorFromRGB(0x858585);
        line.frame = CGRectMake(0, 0, MainScreenSize.width, 0.5);
        [_imageSettingBackgroundView addSubview:line];
        
        [self setupResetBtnAndTrueBtnWith:_imageSettingBackgroundView];
    }
    return _imageSettingBackgroundView;
}

- (void) setHeaderView:(UIView *)headerView
{
    headerView.frame = CGRectMake(0, 64, MainScreenSize.width, headerView.frame.size.height);
    
    UIView *view = [UIView new];
    view.frame = headerView.frame;
    view.backgroundColor = [AppAppearance sharedAppearance].alertBackgroundColor;
    [headerView addSubview:view];
    
    [self.view addSubview:headerView];
    
    if (self.btn_1.selected == YES) {
        if (![headerView.subviews containsObject:self.updateLabel]) {
            [headerView addSubview:self.updateLabel];
        }
    }else {
        if (![headerView.subviews containsObject:self.updateImageView]) {
            [headerView addSubview:self.updateImageView];
        }
    }
    
    _headerView = headerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
//    self.fontNames = [NSMutableDictionary dictionary];
    
    //动态下载 https://developer.apple.com/library/content/samplecode/DownloadFont/Introduction/Intro.html
    self.fonts = @[@"DFWaWaSC-W5",//娃娃体-简 常规体
                   @"STXingkaiSC-Light",//行楷-简 细体
                   @"STKaiti",//华文楷体
                   @"STSongti-SC-Regular",//宋体-简 常规体
                   @"STKaitiSC-Regular",//楷体-简 常规体
                   @"PingFangSC-Regular",];//苹方-简 常规体
    
    self.pointArr = @[@"左上",
                      @"左下",
                      @"右上",
                      @"右下",];
    self.pointNumArr = @[NSStringFromCGPoint(CGPointMake(0, 0)),
                         NSStringFromCGPoint(CGPointMake(0, HeaderViewBottom)),
                         NSStringFromCGPoint(CGPointMake(MainScreenSize.width, 0)),
                         NSStringFromCGPoint(CGPointMake(MainScreenSize.width, HeaderViewBottom)),];
    
    
    [self setupColorImageViews];
    
    
    NSArray *titlesArr = @[@"文字水印设置",@"图片水印设置",];
    
    CGFloat btnW = (MainScreenSize.width - 10)/2;
    for (NSInteger i = 0; i < 2; i++) {
        VS_BottomImageButton *btn = [VS_BottomImageButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:titlesArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:UIColorFromRGB(0x2e2e2e) forState:UIControlStateNormal];
        btn.frame = CGRectMake(0 + btnW * i, HeaderViewBottom, btnW, 41.5);
        btn.tag = 10 + i;
        [btn addTarget:self action:@selector(settingType_Action:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 0) {
            if (self.type_Index == 0) {
                btn.selected = YES;
            }else if (self.type_Index == 1) {
                btn.selected = NO;
            }else {
                btn.selected = YES;
            }
            self.btn_1 = btn;
            [self.view addSubview:self.btn_1];
        }else {
            if (self.type_Index == 0) {
                btn.selected = NO;
            }else if (self.type_Index == 1) {
                btn.selected = YES;
            }else {
                btn.selected = NO;
            }
            self.btn_2 = btn;
            [self.view addSubview:self.btn_2];
        }
    }
    
    UIView *line = [UIView new];
    line.backgroundColor = UIColorFromRGB(0x858585);
    line.frame = CGRectMake(0, self.btn_1.bottom, MainScreenSize.width, 0.5);
    [self.view addSubview:line];
    
    NSArray *labTitles = @[@"文字颜色",@"文字字体",@"文字大小",@"水印位置",];
    
    for (NSInteger i = 0; i < 4; i++) {
        
        UILabel *lab = [self createLab];
        lab.text = labTitles[i];
        lab.frame = CGRectMake(10, HeaderViewBottom + 60 + i*(25+25), 70, 25);
        [lab sizeToFit];
        [self.view addSubview:lab];
        
        if (i == 0) {
            CGFloat imageW = 13;
            for (NSInteger j = 0; j < self.imagesArr.count; j++) {
                UIButton *imageview = [UIButton buttonWithType:UIButtonTypeCustom];
                [imageview setBackgroundImage:self.imagesArr[j] forState:UIControlStateNormal];
                imageview.frame = CGRectMake(lab.right + 10 + j*imageW, lab.top, imageW, imageW);
                imageview.center = CGPointMake(imageview.center.x, lab.center.y);
                imageview.tag = j + 20;
                [imageview addTarget:self action:@selector(textSelectImageAction:) forControlEvents:UIControlEventAllTouchEvents];
                [self.view addSubview:imageview];
                
                if (j == 0) {
                    imageview.layer.borderColor = UIColorFromRGB(0xebebeb).CGColor;
                    imageview.layer.borderWidth = 0.5;
                }
            }
        }else if (i == 1) {
            CGFloat lab_2_W = 40;
            for (NSInteger k = 0; k < self.fonts.count; k++) {
                UIButton *btn_1 = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn_1 setTitle:@"小视秀" forState:UIControlStateNormal];
                [btn_1 setTitleColor:UIColorFromRGB(0x858585) forState:UIControlStateNormal];
                btn_1.titleLabel.font = [UIFont systemFontOfSize:10];
                btn_1.layer.borderColor = btn_1.currentTitleColor.CGColor;
                btn_1.layer.borderWidth = 0.5;
                btn_1.tag = 50 + k;
                [self asynchronouslySetFontName:[self.fonts objectAtIndex:k] btn:btn_1 ChangeSize:NO];
                [btn_1 addTarget:self action:@selector(downloadFontsAction:) forControlEvents:UIControlEventTouchUpInside];
                btn_1.frame = CGRectMake(lab.right + 10 + k*(lab_2_W+5), lab.top, lab_2_W, lab_2_W/1.5);
                [self.view addSubview:btn_1];
            }
        }else if (i == 2) {
            
            UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(lab.right + 10, lab.top, 200, 5)];
            slider.center = CGPointMake(slider.center.x, lab.center.y);
            slider.value = 20;
            slider.minimumValue = 10;
            slider.maximumValue = 30;
            slider.tag = 70;
            [slider addTarget:self action:@selector(SliderTextOrImageChangeFrameWithAction:) forControlEvents:UIControlEventValueChanged];
            slider.minimumTrackTintColor = [AppAppearance sharedAppearance].mainColor;
            [self.view addSubview:slider];
            
        }else {
            CGFloat btn_2_W = 50;
            for (NSInteger m = 0; m < self.pointArr.count; m++) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(lab.right + 10 + m*(btn_2_W + 10), lab.top, btn_2_W, btn_2_W/2);
                btn.center = CGPointMake(btn.center.x, lab.center.y);
                btn.tag = m + 60;
                [btn addTarget:self action:@selector(textOrImageChangeFrameAction:) forControlEvents:UIControlEventTouchUpInside];
                [btn setTitle:self.pointArr[m] forState:UIControlStateNormal];
                [btn setTitleColor:UIColorFromRGB(0x858585) forState:UIControlStateNormal];
                [self.view addSubview:btn];
            }
        }
    }
    
    [self setupResetBtnAndTrueBtnWith:self.view];
    
    //图片水印设置
    NSArray *imageSettingTitles = @[@"图片大小",@"水印位置",];
    for (NSInteger i = 0; i < 2; i++) {
        
        UILabel *lab = [self createLab];
        lab.text = imageSettingTitles[i];
        lab.frame = CGRectMake(10, 20 + i*(25+25), 70, 25);
        [lab sizeToFit];
        [self.imageSettingBackgroundView addSubview:lab];
        
        if (i == 0) {
            
            UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(lab.right + 10, lab.top, 200, 5)];
            slider.center = CGPointMake(slider.center.x, lab.center.y);
            slider.value = 1;
            slider.minimumValue = 0.3;
            slider.maximumValue = 1.5;
            slider.tag = 90;
            slider.minimumTrackTintColor = [AppAppearance sharedAppearance].mainColor;
            [slider addTarget:self action:@selector(SliderTextOrImageChangeFrameWithAction:) forControlEvents:UIControlEventValueChanged];
            [self.imageSettingBackgroundView addSubview:slider];
        }else{
            
            CGFloat btn_2_W = 50;
            for (NSInteger m = 0; m < self.pointArr.count; m++) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(lab.right + 10 + m*(btn_2_W + 10), lab.top, btn_2_W, btn_2_W/2);
                btn.center = CGPointMake(btn.center.x, lab.center.y);
                btn.tag = m + 60;
                [btn addTarget:self action:@selector(textOrImageChangeFrameAction:) forControlEvents:UIControlEventTouchUpInside];
                [btn setTitle:self.pointArr[m] forState:UIControlStateNormal];
                [btn setTitleColor:UIColorFromRGB(0x858585) forState:UIControlStateNormal];
                [self.imageSettingBackgroundView addSubview:btn];
            }
        }
    }
}

- (void) setupResetBtnAndTrueBtnWith:(UIView *)backgroundView
{
    CGFloat btn_width = (MainScreenSize.width-40)/2;
    for (NSInteger i = 0; i < 2; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(10 + (btn_width+20)*i, backgroundView.height - 44-HeaderViewBottom, btn_width, 44);
        btn.layer.cornerRadius = 5;
        [btn setTitle:(i==0)?@"重置":@"确定" forState:UIControlStateNormal];
        [btn setBackgroundColor:[AppAppearance sharedAppearance].mainColor];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.tag = 100 + i;
        [btn addTarget:self action:@selector(BottomBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:btn];
    }
}

#pragma mark - 提交或重置 -
- (void) BottomBtnAction:(UIButton *)btn
{
    //重置
    if (btn.tag == 100) {
        
        if (self.updateLabel.hidden == NO) {//文字水印
            
            [self resetUpdateLabel];
        }else {
            [self resetUpdateImageView];
        }
    }else {//确定
        //请求网络
        if (self.updateLabel.hidden == NO) {//文字水印
            
            NSLog(@"fontName = %@, rect = %@, color = %@",self.updateLabel.font.fontName,NSStringFromCGRect(self.updateLabel.frame),[AppTool toStrByUIColor:self.updateLabel.textColor]);
            [lz_VideoTemplateModel requestUserWaterUploadWithType:@"text"
                                                         position:[NSNumber numberWithInteger:1]
                                                            image:@""
                                                             face:@"FZSEJW.ttf"
                                                             size:[NSNumber numberWithInteger:self.updateLabel.font.pointSize]
                                                            color:[AppTool toStrByUIColor:self.updateLabel.textColor]
                                                             text:self.updateLabel.text
                                                    SuccessHandle:^(id responseObject) {
                                                        
                                                        [self HudShowWithStatus:@"上传成功"];
                                                        
                                                    } FailureHandle:^(NSError *error) {
                                                        
                                                    }];
        }else {
            [lz_VideoTemplateModel requestUploadTemplateImage:self.updateImageView.image
                                                     fileName:nil
                                                 parameteName:nil
                                                SuccessHandle:^(id responseObject) {
                                                    
                                                    [lz_VideoTemplateModel requestUserWaterUploadWithType:@"image"
                                                                                                 position:[NSNumber numberWithInteger:1]
                                                                                                    image:responseObject[@"image"]
                                                                                                     face:@""
                                                                                                     size:@0
                                                                                                    color:@""
                                                                                                     text:@""
                                                                                            SuccessHandle:^(id responseObject) {
                                                                                                
                                                                                                [self HudShowWithStatus:@"上传成功"];
                                                                                                
                                                                                            } FailureHandle:^(NSError *error) {
                                                                                                
                                                                                            }];
                                                    
                                                } FailureHandle:^(NSError *error) {
                                                    
                                                    [self HudHide];
                                                    [self HudShowWithStatus:@"上传失败"];
                                                } progressHandle:^(NSProgress *progress) {
                                                    
                                                    NSString *num_Str_1 = [NSString stringWithFormat:@"%.2lld",progress.completedUnitCount];
                                                    NSString *num_Str_2 = [NSString stringWithFormat:@"%.2lld",progress.totalUnitCount];
                                                    NSString *numStr = [NSString stringWithFormat:@"%.2f",num_Str_1.floatValue/num_Str_2.floatValue];
                                                    //                                                NSLog(@"numStr = %@",numStr);
                                                    [self HudShowProgress:(numStr.floatValue) status:progress.localizedDescription];
                                                }];

        }
    }
}

//拖动控件
- (void) panUploadLabelOrImage:(UIPanGestureRecognizer *)pan
{
    if ([pan.view isKindOfClass:[UITextField class]]) {
        
        CGPoint point = [pan locationInView:self.updateLabel.superview];
        if (point.x < self.updateLabel.width/2) {
            point = CGPointMake(self.updateLabel.width/2, point.y);
        }
        if (point.x > self.headerView.width-self.updateLabel.width/2) {
            point = CGPointMake(self.headerView.width-self.updateLabel.width/2, point.y);
        }
        if (point.y < self.updateLabel.height/2) {
            point = CGPointMake(point.x, self.updateLabel.height/2);
        }
        if (point.y > self.headerView.height-self.updateLabel.height/2) {
            point = CGPointMake(point.x, self.headerView.height-self.updateLabel.height/2);
        }
        self.updateLabel.center = point;
        
    }else if ([pan.view isKindOfClass:[UIImageView class]]) {
        
        CGPoint point = [pan locationInView:self.updateImageView.superview];
        if (point.x < self.updateImageView.width/2) {
            point = CGPointMake(self.updateImageView.width/2, point.y);
        }
        if (point.x > self.headerView.width-self.updateImageView.width/2) {
            point = CGPointMake(self.headerView.width-self.updateImageView.width/2, point.y);
        }
        if (point.y < self.updateImageView.height/2) {
            point = CGPointMake(point.x, self.updateImageView.height/2);
        }
        if (point.y > self.headerView.height-self.updateImageView.height/2) {
            point = CGPointMake(point.x, self.headerView.height-self.updateImageView.height/2);
        }
        self.updateImageView.center = point;
        
    }else {
        
    }
}

//选取图片
- (void) tapUploadLabelOrImage:(UITapGestureRecognizer *)tap
{
    if ([tap.view isKindOfClass:[UIImageView class]]) {
        
        [self.navigationController presentViewController:self.imagePickController animated:YES completion:NULL];
    }else if ([tap.view isKindOfClass:[UITextField class]]) {
        
        
    }else {}
}

//选取颜色
- (void) textSelectImageAction:(UIButton *)btn
{
    NSLog(@"tag = %ld",btn.tag - 20);
    self.updateLabel.textColor = [self.colorsArr objectAtIndex:(btn.tag - 20)];
}

//下载字体库
- (void) downloadFontsAction:(UIButton *)btn
{
    [self asynchronouslySetFontName:[self.fonts objectAtIndex:btn.tag - 50] btn:btn ChangeSize:YES];
    NSLog(@"tag = %ld",btn.tag - 50);
}

- (void) SliderTextOrImageChangeFrameWithAction:(UISlider *)slider
{
    //文字水印
    if (slider.tag == 70) {
        
        CGPoint point = self.updateLabel.center;
        self.updateLabel.font = [UIFont fontWithName:self.updateLabel.font.fontName size:slider.value];
        [self.updateLabel sizeToFit];
        self.updateLabel.center = point;
        
    }else {
        
        CGPoint point = self.updateImageView.center;
        self.updateImageView.size = CGSizeMake(100 * slider.value, 100 * slider.value);
        self.updateImageView.center = point;
        
        UIImageView *anImageView = [self.updateImageView viewWithTag:10];
        anImageView.frame = CGRectMake(_updateImageView.width-10, -10, 20, 20);
    }
}

- (void) imageChangeBoundsWithPan:(UIPanGestureRecognizer *)pan
{
    if ([pan.view isKindOfClass:[UIImageView class]]) {
        CGPoint point = self.updateImageView.center;
        CGPoint panPoint = [pan locationInView:self.headerView];
        self.updateImageView.size = CGSizeMake((panPoint.x-point.x)*2, (point.y-panPoint.y)*2);
        self.updateImageView.center = point;
        
        UIImageView *panGesImageView = [self.updateImageView viewWithTag:10];
        panGesImageView.frame = CGRectMake(self.updateImageView.width-10, -10, 20, 20);
    }
}

//位置改变
- (void) textOrImageChangeFrameAction:(UIButton *)btn
{
    if (self.btn_1.selected) {
        for (NSInteger i = 0; i < self.pointArr.count; i++) {
            UIButton *temp = [self.view viewWithTag:60+i];
            if (!temp) {
                temp = [self.imageSettingBackgroundView viewWithTag:60+i];
            }
            temp.layer.borderWidth = 0;
            temp.layer.borderColor = [UIColor clearColor].CGColor;
        }
        
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = [AppAppearance sharedAppearance].mainColor.CGColor;
        NSLog(@"tag = %ld",btn.tag - 60);
        
        
        CGSize updateLabelSize = self.updateLabel.size;
        
        if (btn.tag == 60) {
            
            self.updateLabel.frame = CGRectMake(0, 0, self.updateLabel.frame.size.width, self.updateLabel.frame.size.height);
        }else if (btn.tag == 61) {
            
            self.updateLabel.frame = CGRectMake(0, self.headerView.bounds.size.height - updateLabelSize.height, updateLabelSize.width, updateLabelSize.height);
        }else if (btn.tag == 62) {
            
            self.updateLabel.frame = CGRectMake(MainScreenSize.width - updateLabelSize.width, 0, updateLabelSize.width, updateLabelSize.height);
        }else{
            
            self.updateLabel.frame = CGRectMake(MainScreenSize.width - updateLabelSize.width, self.headerView.bounds.size.height - updateLabelSize.height, updateLabelSize.width, self.updateLabel.frame.size.height);
        }
    }else if (self.btn_2.selected) {
        
        for (NSInteger i = 0; i < self.pointArr.count; i++) {
            UIButton *temp = [self.imageSettingBackgroundView viewWithTag:60+i];
            temp.layer.borderWidth = 0;
            temp.layer.borderColor = [UIColor clearColor].CGColor;
        }
        
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = [AppAppearance sharedAppearance].mainColor.CGColor;
        NSLog(@"tag = %ld",btn.tag - 60);
        
        
        CGSize updateImageViewSize = self.updateImageView.size;
        
        if (btn.tag == 60) {
            
            self.updateImageView.frame = CGRectMake(0, 0, self.updateImageView.frame.size.width, self.updateImageView.frame.size.height);
        }else if (btn.tag == 61) {
            
            self.updateImageView.frame = CGRectMake(0, self.headerView.bounds.size.height - updateImageViewSize.height, updateImageViewSize.width, updateImageViewSize.height);
        }else if (btn.tag == 62) {
            
            self.updateImageView.frame = CGRectMake(MainScreenSize.width - updateImageViewSize.width, 0, updateImageViewSize.width, updateImageViewSize.height);
        }else{
            
            self.updateImageView.frame = CGRectMake(MainScreenSize.width - updateImageViewSize.width, self.headerView.bounds.size.height - updateImageViewSize.height, updateImageViewSize.width, self.updateImageView.frame.size.height);
        }
        
    }else {
        
    }
}

- (void) setupColorImageViews
{
    self.colorsArr = @[ UIColorFromRGB(0xffffff),
                        UIColorFromRGB(0xcccccc),
                        UIColorFromRGB(0x404040),
                        UIColorFromRGB(0x000000),
                        UIColorFromRGB(0xbe8145),
                        UIColorFromRGB(0x7f0100),
                        UIColorFromRGB(0xfe0100),
                        UIColorFromRGB(0xfe5600),
                        UIColorFromRGB(0xfe8100),
                        UIColorFromRGB(0xfdc000),
                        UIColorFromRGB(0xa7e201),
                        UIColorFromRGB(0x6bbf00),
                        UIColorFromRGB(0x008d00),
                        UIColorFromRGB(0x80d5ff),
                        UIColorFromRGB(0x0097ff),
                        UIColorFromRGB(0x0067cb),
                        UIColorFromRGB(0x001b65),
                        UIColorFromRGB(0x74018b),
                        UIColorFromRGB(0xfe1b81),
                        UIColorFromRGB(0xf97aa2),];
    self.imagesArr = [NSMutableArray array];
    
    [self.colorsArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImage *temp = [AppTool createImageFromColor:self.colorsArr[idx] withRect:CGRectMake(0, 0, 1, 1)];
        [self.imagesArr addObject:temp];
    }];
}

- (UILabel *) createLab
{
    UILabel *lab = [UILabel new];
    lab.textColor = UIColorFromRGB(0x2e2e2e);
//    lab.font = [UIFont systemFontOfSize:12];
    lab.font = [UIFont systemFontOfSize:12 weight:1];
    [lab setSize:CGSizeMake(80, 30)];
    lab.textAlignment = NSTextAlignmentLeft;
    
    return lab;
}

- (void) showPicOrText:(NSInteger)type_Index;
{
    if (type_Index == 0) {
        
        self.btn_1.selected = YES;
        self.btn_2.selected = NO;
        
        if (![self.headerView.subviews containsObject:self.updateLabel]) {
            [self.headerView addSubview:self.updateLabel];
        }
        self.updateLabel.hidden = NO;
        
        self.imageSettingBackgroundView.hidden = YES;
        
    }else if (type_Index == 1) {
        
        self.btn_1.selected = NO;
        self.btn_2.selected = YES;
        
        if (![self.headerView.subviews containsObject:self.updateLabel]) {
            [self.headerView addSubview:self.updateLabel];
        }
        self.updateLabel.hidden = YES;
        
        if (![self.view.subviews containsObject:self.imageSettingBackgroundView]) {
            [self.view addSubview:self.imageSettingBackgroundView];
        }
        self.imageSettingBackgroundView.hidden = NO;
        
    }else {
        
    }
}

//切换水印设置类型
- (void) settingType_Action:(UIButton *)btn
{
    if (btn.tag == 10) {
        
        if (btn.selected == NO) {
            self.btn_2.selected = !self.btn_2.selected;
            btn.selected = !btn.selected;
            
//            NSLog(@"点击了%@btn,状态是%d",btn.titleLabel.text,btn.selected);
            
            if (![self.headerView.subviews containsObject:self.updateLabel]) {
                [self.headerView addSubview:self.updateLabel];
            }
            self.updateLabel.hidden = NO;
            
            self.imageSettingBackgroundView.hidden = YES;
            
            if ([self.headerView.subviews containsObject:self.updateImageView]) {
                self.updateImageView.hidden = YES;
            }
        }
    }else {
        if (btn.selected == NO) {
            self.btn_1.selected = !self.btn_1.selected;
            btn.selected = !btn.selected;
            
            if (![self.headerView.subviews containsObject:self.updateLabel]) {
                [self.headerView addSubview:self.updateLabel];
            }
            self.updateLabel.hidden = YES;
            
            if (![self.view.subviews containsObject:self.imageSettingBackgroundView]) {
                [self.view addSubview:self.imageSettingBackgroundView];
            }
            self.imageSettingBackgroundView.hidden = NO;
//            NSLog(@"点击了%@btn,状态是%d",btn.titleLabel.text,btn.selected);
            
            if ([self.headerView.subviews containsObject:self.updateImageView]) {
                self.updateImageView.hidden = NO;
            }else {
                [self.headerView addSubview:self.updateImageView];
            }
            [self resetUpdateImageView];
        }
    }
}


//获取字体大小
//isChangeSize  ： 是否需要改变字体大小
- (void)asynchronouslySetFontName:(NSString *)fontName btn:(UIButton *)titleBtn ChangeSize:(BOOL)isChangeSize
{
    UIFont* aFont = [UIFont fontWithName:fontName size:isChangeSize==YES?self.updateLabel.font.pointSize:12];
    // If the font is already downloaded
    if (aFont && ([aFont.fontName compare:fontName] == NSOrderedSame || [aFont.familyName compare:fontName] == NSOrderedSame)) {
        // Go ahead and display the sample text.
        
//        [self.fontNames setValue:aFont forKey:[NSString stringWithFormat:@"%ld",titleBtn.tag]];
        isChangeSize==YES?(self.updateLabel.font=aFont):(titleBtn.titleLabel.font = aFont);
        
        return;
    }else {
        
        //如果没有这一个字体就去下载
        [self asynchronouslySetFontName:fontName btn:titleBtn];
    }
}

//下载字体
- (void)asynchronouslySetFontName:(NSString *)fontName btn:(UIButton *)titleBtn
{
    // Create a dictionary with the font's PostScript name.
    NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:fontName, kCTFontNameAttribute, nil];
    
    // Create a new font descriptor reference from the attributes dictionary.
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)attrs);
    
    NSMutableArray *descs = [NSMutableArray arrayWithCapacity:0];
    [descs addObject:(__bridge id)desc];
    CFRelease(desc);
    
    __block BOOL errorDuringDownload = NO;
    
    // Start processing the font descriptor..
    // This function returns immediately, but can potentially take long time to process.
    // The progress is notified via the callback block of CTFontDescriptorProgressHandler type.
    // See CTFontDescriptor.h for the list of progress states and keys for progressParameter dictionary.
    
    CTFontDescriptorMatchFontDescriptorsWithProgressHandler( (__bridge CFArrayRef)descs, NULL,  ^(CTFontDescriptorMatchingState state, CFDictionaryRef progressParameter) {
        
        //NSLog( @"state %d - %@", state, progressParameter);
        
        double progressValue = [[(__bridge NSDictionary *)progressParameter objectForKey:(id)kCTFontDescriptorMatchingPercentage] doubleValue];
        
        if (state == kCTFontDescriptorMatchingDidBegin) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                // Show an activity indicator
                
                // Show something in the text view to indicate that we are downloading
                
                NSLog(@"开始匹配字体");
            });
        } else if (state == kCTFontDescriptorMatchingDidFinish) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                // Remove the activity indicator
                
                
                // Display the sample text for the newly downloaded font
                
                // Log the font URL in the console
                CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)fontName, 0., NULL);
                CFStringRef fontURL = CTFontCopyAttribute(fontRef, kCTFontURLAttribute);
                //                NSLog(@"%@", (__bridge NSString*)(fontURL));
                CFRelease(fontURL);
                CFRelease(fontRef);
                
                if (!errorDuringDownload) {
                    NSLog(@"%@ 匹配完毕", fontName);
                    //匹配完毕重新调用方法更新btn的UI
                    [self asynchronouslySetFontName:fontName btn:titleBtn ChangeSize:NO];
                }
            });
        } else if (state == kCTFontDescriptorMatchingWillBeginDownloading) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                // Show a progress bar
                NSLog(@"开始下载字体库，第一次下载较慢，请稍候");
            });
        } else if (state == kCTFontDescriptorMatchingDidFinishDownloading) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                // Remove the progress bar
                NSLog(@"下载完毕");
                //下载完毕重新调用方法更新btn的UI
                [self asynchronouslySetFontName:fontName btn:titleBtn ChangeSize:NO];
            });
        } else if (state == kCTFontDescriptorMatchingDownloading) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                // Use the progress bar to indicate the progress of the downloading
                
                [SVProgressHUD showProgress:progressValue / 100.0 status:[NSString stringWithFormat:@"正在下载%@字体,请稍候",fontName]];
//                NSLog(@"下载进度 %.0f%% complete", progressValue);
            });
        } else if (state == kCTFontDescriptorMatchingDidFailWithError) {
            // An error has occurred.
            // Get the error message
            NSError *error = [(__bridge NSDictionary *)progressParameter objectForKey:(id)kCTFontDescriptorMatchingError];
            if (error != nil) {
                _errorMessage = [error description];
            } else {
                _errorMessage = @"ERROR MESSAGE IS NOT AVAILABLE!";
            }
            // Set our flag
            errorDuringDownload = YES;
            
            dispatch_async( dispatch_get_main_queue(), ^ {
                NSLog(@"下载失败原因: %@", _errorMessage);
            });
        }
        
        return (bool)YES;
    });
}

//选取图片delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo;
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        self.updateImageView.image = image;
    }];
}


- (BOOL)isOpenPopGestureRecognizer
{
    return NO;
}

@end
