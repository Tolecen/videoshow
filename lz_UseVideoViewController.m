//
//  lz_UseVideoViewController.m
//  videoshow
//
//  Created by gutou on 2017/3/8.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "lz_UseVideoViewController.h"
#import "lz_TextViewController.h"
#import "lz_FetchImageViewController.h"

#import "lz_VideoTemplateModel.h"

@interface lz_UseVideoViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@property (nonatomic, strong) UIButton *currentSelectBtn;//用来存储当前操作的button

@property (nonatomic, strong) NSMutableArray *resources;

@end

@implementation lz_UseVideoViewController

//是否可以提交素材
- (BOOL) isCanUpload
{
    if (self.template_id && self.resources.count) {
        return YES;
    }else {
        return NO;
    }
}

- (BOOL) shouldShowGetMore
{
    return NO;
}

- (BOOL) shouldShowRefresh
{
    return NO;
}

- (void) showNextItemAction:(UIButton *)button
{
//    NSLog(@"提交数据");
    if (![self isCanUpload]) {
        
        [self HudShowWithStatus:@"素材不完整无法提交"];
        return;
    }
    
    [self HudShowWithStatus:@"正在上传"];
    //判断图片内容 text内容
    [lz_VideoTemplateModel requestUploadTemplateTaskWithTemplate_id:self.template_id
                                                          resources:self.resources
                                                      SuccessHandle:^(id responseObject) {
                                                          
                                                          if (responseObject[@"message"]) {
                                                              [self HudShowWithStatus:responseObject[@"message"]];
                                                          }
                                                          [self showBackItemAction:nil];
                                                      } FailureHandle:^(NSError *error) {
                                                          [self HudShowWithStatus:@"上传失败" Delay:1.5];
                                                      }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"添加图片";
    [self showBackItem];
    [self showNextItem];
    self.resources = [NSMutableArray array];
    
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    _imagePickerController.allowsEditing = NO;
    self.imagePickerController.delegate = self;
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (UICollectionViewFlowLayout *) flowLayout
{
    UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
    flowlayout.itemSize = CGSizeMake((MainScreenSize.width-40)/3, 60);
    flowlayout.minimumLineSpacing = 10;
    flowlayout.minimumInteritemSpacing = 10;
    flowlayout.sectionInset = UIEdgeInsetsMake(10, 10, 0, 10);
    
    return flowlayout;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    NSLog(@"子类需要重写%s",__FUNCTION__);
    return self.datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self collectionCellIdentifier] forIndexPath:indexPath];
    NSInteger arrIndex = indexPath.item;
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [btn setTitleColor:UIColorFromRGB(0x858585) forState:UIControlStateNormal];
    if ([self.datas[arrIndex][@"type"] isEqual:@"text"]) {//文字
        [btn setTitle:@"添加文字" forState:UIControlStateNormal];
        btn.layer.borderColor = UIColorFromRGB(0x85885).CGColor;
        btn.layer.borderWidth = 0.5;
    }else {
//            [btn setTitle:@"添加图片" forState:UIControlStateNormal];
        btn.imageView.clipsToBounds = NO;
        [btn setBackgroundImage:[UIImage imageNamed:@"tianjiazhaop"] forState:UIControlStateNormal];
    }
    
    btn.tag = 10 + arrIndex;
    [btn addTarget:self action:@selector(getPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    if (cell.contentView.subviews.count<2) {
        [cell.contentView addSubview:btn];
    }
    
    btn.frame = CGRectMake(0, 0, cell.contentView.width, cell.contentView.height);
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void) getPhotoAction:(UIButton *)btn
{
    self.currentSelectBtn = btn;
    
    if ([self.datas[btn.tag-10][@"type"] isEqual:@"text"]) {//文字
        
        lz_TextViewController *vc = [[lz_TextViewController alloc] init];
        vc.uploadKey = self.datas[btn.tag-10][@"key"];
        WeakTypeof(weakSelf)
        vc.textBlock = ^(NSDictionary *dict) {
            
            NSString *resultText = dict[@"value"];
            
            NSLog(@"回调内容 = %@",resultText);
            [weakSelf.currentSelectBtn setTitle:resultText forState:UIControlStateNormal];
            [weakSelf.currentSelectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            weakSelf.currentSelectBtn.titleLabel.numberOfLines = 0;
            [weakSelf.resources addObject:dict];
        };
        
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        
        if (![self isImageSameLeftImage:self.currentSelectBtn.currentBackgroundImage rightImage:[UIImage imageNamed:@"tianjiazhaop"]]) {
            
            lz_FetchImageViewController *vc = [[lz_FetchImageViewController alloc] init];
            vc.uploadDict = self.datas[self.currentSelectBtn.tag-10];
//            vc.uploadKey = self.datas[self.currentSelectBtn.tag-10][@"key"];
            vc.ImageTag = self.currentSelectBtn.tag-10;
            vc.defaultImage = self.currentSelectBtn.currentBackgroundImage;
            WeakTypeof(weakSelf)
            vc.ImageBlock = ^(UIImage *image) {
                
//        NSLog(@"回调image = %@",image);
                [weakSelf.currentSelectBtn setBackgroundImage:image forState:UIControlStateNormal];
            };
            vc.ImageDeleteBlock = ^(void){
                [weakSelf.currentSelectBtn setBackgroundImage:[UIImage imageNamed:@"tianjiazhaop"] forState:UIControlStateNormal];
            };
            vc.returnDataBlock = ^(NSDictionary *dict) {
                
                [weakSelf.resources addObject:dict];
//        NSLog(@"dict = %@",dict);
            };
            [self.navigationController pushViewController:vc animated:YES];
            
        }else {
            [self presentViewController:_imagePickerController animated:YES completion:nil];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
//    NSLog(@"选择完毕----image:%@-----info:%@",image,editingInfo);
    
//    self.imageView_1.image = image;
    
    lz_FetchImageViewController *vc = [[lz_FetchImageViewController alloc] init];
    vc.uploadDict = self.datas[self.currentSelectBtn.tag-10];
//    vc.uploadKey = self.datas[self.currentSelectBtn.tag-10][@"key"];
    vc.ImageTag = self.currentSelectBtn.tag-10;
    vc.defaultImage = image;
    WeakTypeof(weakSelf)
    vc.ImageBlock = ^(UIImage *image) {
        
//        NSLog(@"回调image = %@",image);
        [weakSelf.currentSelectBtn setBackgroundImage:image forState:UIControlStateNormal];
    };
    vc.ImageDeleteBlock = ^(void){
        [weakSelf.currentSelectBtn setBackgroundImage:[UIImage imageNamed:@"tianjiazhaop"] forState:UIControlStateNormal];
    };
    vc.returnDataBlock = ^(NSDictionary *dict) {
      
        [weakSelf.resources addObject:dict];
//        NSLog(@"dict = %@",dict);
    };
    [self.navigationController pushViewController:vc animated:YES];
    
    [self.imagePickerController dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL) isImageSameLeftImage:(UIImage *)leftImage rightImage:(UIImage *)rightImage
{
    NSData *data1 = UIImagePNGRepresentation(leftImage);
    NSData *data2 = UIImagePNGRepresentation(rightImage);
    if ([data1 isEqual: data2]) {
        return YES;
    }else {
        return NO;
    }
}

@end
