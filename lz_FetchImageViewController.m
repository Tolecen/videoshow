//
//  lz_FetchImageViewController.m
//  videoshow
//
//  Created by gutou on 2017/3/20.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "lz_FetchImageViewController.h"
#import "UIView+UIScreenDisplay.h"
#import "ImageCropperView.h"
#import "lz_VideoTemplateModel.h"
#import "UIImage+SubImage.h"

#define Scroll_Image_Height (300)

@interface lz_FetchImageViewController ()

@property (nonatomic, strong)  ImageCropperView *cropper;
@property (nonatomic, strong)  UIImage *resultImage;

@property (nonatomic, assign) BOOL isCanLeaveCurrent;//是否可以离开

@end

@implementation lz_FetchImageViewController
@synthesize cropper, resultImage;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self showBackItem];
    [self showDeleteItem];
    self.view.backgroundColor = [UIColor whiteColor];

    cropper = [[ImageCropperView alloc] initWithFrame:CGRectMake(0, 0, MainScreenSize.width, Scroll_Image_Height)];
    [self.view addSubview:cropper];
    cropper.layer.borderWidth = 1.0;
    cropper.layer.borderColor = [AppAppearance sharedAppearance].mainColor.CGColor;
    [cropper setup];
    cropper.image = self.defaultImage;

    CGFloat btn_width = (MainScreenSize.width-40)/2;
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(10, MainScreenSize.height-44-64-20, btn_width, 44);
    cancelBtn.tag = 10;
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.backgroundColor = [AppAppearance sharedAppearance].mainColor;
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:cancelBtn];
    
    UIButton *uploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    uploadBtn.frame = CGRectMake(cancelBtn.right+20, MainScreenSize.height-44-64-20, btn_width, 44);
    [uploadBtn setTitle:@"确定" forState:UIControlStateNormal];
    uploadBtn.backgroundColor = [AppAppearance sharedAppearance].mainColor;
    [uploadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:uploadBtn];
    
    [uploadBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonClicked:(UIButton *)btn
{
    //取消
    if (btn.tag == 10) {
        [cropper reset];

        [self.navigationController popViewControllerAnimated:YES];
    }else {
        
        //提交数据
        [cropper finishCropping];
        resultImage = cropper.croppedImage;

        //正在提交图片素材
        [self HudShowWithStatus:@"正在提交图片素材"];
        
        NSString * parmaeName;
        if (self.ImageTag == 0) {
            parmaeName = [NSString stringWithFormat:@"image"];
        }else {
            parmaeName = [NSString stringWithFormat:@"image%ld",self.ImageTag];
        }
        
        //处理图片至指定尺寸
        resultImage = [resultImage rescaleImageToSize:CGSizeMake([self.uploadDict[@"width"] integerValue], [self.uploadDict[@"height"] integerValue])];
        
        [lz_VideoTemplateModel requestUploadTemplateImage:resultImage
                                                 fileName:self.uploadDict[@"key"]
                                             parameteName:parmaeName
                                            SuccessHandle:^(id responseObject) {
                                                
                                                self.isCanLeaveCurrent = YES;
                                                [self HudShowWithStatus:@"上传成功"];
                                                
                                                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                                                [dict setValue:[responseObject valueForKey:parmaeName] forKey:@"value"];
                                                [dict setValue:self.uploadDict[@"key"] forKey:@"key"];
                                                [dict setValue:@"image" forKey:@"type"];
                                                if (self.returnDataBlock) {
                                                    self.returnDataBlock(dict);
                                                }
                                                if (self.ImageBlock) {
                                                    self.ImageBlock(resultImage);
                                                }
                                                
                                                [self.navigationController popViewControllerAnimated:YES];
                                            } FailureHandle:^(NSError *error) {
                                                
                                                [self HudHide];
                                                [self HudShowWithStatus:@"上传失败"];
                                            } progressHandle:^(NSProgress *progress) {
                                                
                                                self.isCanLeaveCurrent = NO;
                                                NSString *num_Str_1 = [NSString stringWithFormat:@"%.2lld",progress.completedUnitCount];
                                                NSString *num_Str_2 = [NSString stringWithFormat:@"%.2lld",progress.totalUnitCount];
                                                NSString *numStr = [NSString stringWithFormat:@"%.2f",num_Str_1.floatValue/num_Str_2.floatValue];
//                                                NSLog(@"numStr = %@",numStr);
                                                [self HudShowProgress:(numStr.floatValue) status:progress.localizedDescription];
                                            }];
    }
}

- (void) showDeleteItemAction:(UIButton *)button
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定要删除吗" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *trueAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //删除图片
        if (self.ImageDeleteBlock) {
            self.ImageDeleteBlock();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alert addAction:trueAction];
    [alert addAction:cancelAction];
    [self.navigationController presentViewController:alert animated:YES completion:^{
        
    }];
}

@end
