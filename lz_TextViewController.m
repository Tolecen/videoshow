//
//  lz_TextViewController.m
//  videoshow
//
//  Created by gutou on 2017/3/9.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "lz_TextViewController.h"
//#import "lz_VideoTemplateModel.h"
#import "VS_Choose_AlertView.h"

@interface lz_TextViewController ()<UITextViewDelegate>

@property (nonatomic, strong) UITextView *inputTextView;

@end

@implementation lz_TextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"文本编辑";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self showBackItem];
    
    self.inputTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, MainScreenSize.width - 20, 150)];
    self.inputTextView.textColor = [UIColor darkTextColor];
    self.inputTextView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.inputTextView.layer.borderWidth = 1;
    self.inputTextView.delegate = self;
    [self.inputTextView setText:@"请输入您对该视频的描述"];
    self.inputTextView.textColor = UIColorFromRGB(0x929292);
    [self.view addSubview:self.inputTextView];
    
    UIButton *trueBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [trueBtn setTitle:@"确定" forState:UIControlStateNormal];
    [trueBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [trueBtn setBackgroundColor:[AppAppearance sharedAppearance].mainColor];
    trueBtn.layer.cornerRadius = 5;
    trueBtn.frame = CGRectMake(10, self.inputTextView.bottom + 100, MainScreenSize.width - 20, 44);
    [self.view addSubview:trueBtn];
    [trueBtn addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL) textViewShouldEndEditing:(UITextView *)textView
{
    if (!textView.text.length) {
        textView.text = @"请输入您对该视频的描述";
        textView.textColor = UIColorFromRGB(0x929292);
    }
    return YES;
}

- (void) textViewDidChange:(UITextView *)textView
{
    if (!textView.text.length) {
        textView.text = @"请输入您对该视频的描述";
    }
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"请输入您对该视频的描述"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void) action:(UIButton *)btn
{
    if ([self.inputTextView.text isEqualToString:@"请输入您对该视频的描述"]) {
        
    }else {
        
        WeakTypeof(weakSelf)
        VS_Choose_AlertView *view = [[VS_Choose_AlertView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        view.block = ^(WaterMarkType type) {
            
            if (type == WaterMarkType_PicWaterMark) {
                
                if (weakSelf.textBlock) {
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setValue:weakSelf.uploadKey forKey:@"key"];
                    [dict setValue:weakSelf.inputTextView.text forKey:@"value"];
                    [dict setValue:@"text" forKey:@"type"];
                    weakSelf.textBlock(dict);
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        };
        [view setTitles:@[@"编辑成功",@"提交生成"]];
        [view show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
