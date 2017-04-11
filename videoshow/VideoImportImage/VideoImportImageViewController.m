//
//  VideoImportImageViewController.m
//  Babypai
//
//  Created by ning on 16/5/17.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "VideoImportImageViewController.h"
#import "TZImagePickerController.h"
#import "CellImportImage.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "LxGridViewFlowLayout.h"
#import "UIButton+Extension.h"
#import "ImageUtils.h"
#import "MediaObject.h"
#import "BabyFileManager.h"
#import "TZImageManager.h"
#import "SVProgressHUD.h"
#import <IJKMediaFramework/VideoEncoder.h>
#import "ThemeHelper.h"
#import "VideoPreviewViewController.h"

#define IMAGE_COUNT_MIN 3
#define IMAGE_COUNT_MAX 5

@interface VideoImportImageViewController ()<TZImagePickerControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate> {
    NSMutableArray *_selectedPhotos;
    NSMutableArray *_selectedAssets;
    
    CGFloat _itemWH;
    CGFloat _margin;
    LxGridViewFlowLayout *_layout;
}
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) UIButton *startBtn;

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) MediaObject *mMediaObject;

@property (nonatomic, strong) MediaPart *mMediaPart;

@property (nonatomic, assign) int imageCount;

@property (nonatomic, strong) NSMutableArray *filePaths;

@property (nonatomic, strong) NSMutableArray *imagePaths;
/**
 * 公共文件
 */
@property (nonatomic, strong) NSString *mThemeCommonPath;

@property (nonatomic, assign) BOOL hasSavedDraft;

@end

@implementation VideoImportImageViewController

- (NSString *)title
{
    return @"照片视频";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showBackItem];
    _selectedPhotos = [NSMutableArray array];
    _selectedAssets = [NSMutableArray array];
    _imagePaths = [NSMutableArray array];
    self.mThemeCommonPath = [[[BabyFileManager manager] themeDir] stringByAppendingPathComponent:THEME_VIDEO_COMMON];
    [self configCollectionView];
    
//    UIImage *image = [ImageUtils handleImage:ImageNamed(@"ic_set_media_public_psd") withSize:CGSizeMake(480 / SCREEN_SCALE, 480 / SCREEN_SCALE)];
//    
//    UIImageView *ig = [[UIImageView alloc]initWithImage:image];
//    
//    ig.frame = CGRectMake(20, 20 + TopBar_height, ig.frame.size.width, ig.frame.size.height);
//    
//    [self.view addSubview:ig];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
self.navigationController.navigationBar.barTintColor = [AppAppearance sharedAppearance].mainColor;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    //[MobClick beginLogPageView:[self title]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[MobClick endLogPageView:[self title]];
}

- (void)configCollectionView {
    _layout = [[LxGridViewFlowLayout alloc] init];
    _margin = 4;
    _itemWH = (SCREEN_WIDTH - 2 * _margin - 4) / 3 - _margin;
    _layout.itemSize = CGSizeMake(_itemWH, _itemWH);
    _layout.minimumInteritemSpacing = _margin;
    _layout.minimumLineSpacing = _margin;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(_margin, 0, SCREEN_WIDTH - 2 * _margin, SCREEN_HEIGHT - 64 -48- 36) collectionViewLayout:_layout];
    _collectionView.backgroundColor = UIColorFromRGB(BABYCOLOR_background);
    _collectionView.contentInset = UIEdgeInsetsMake(4, 0, 0, 2);
    _collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, -2);
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[CellImportImage class] forCellWithReuseIdentifier:NSStringFromClass([CellImportImage class])];
    
    UIButton *startBtn = [UIButton createButtonWithTitle:@"开始制作" target:self action:@selector(startMakeVideo) type:BUTTON_TYPE_RED];
    startBtn.frame = CGRectMake(_margin, SCREEN_HEIGHT - 64-48, SCREEN_WIDTH - 2 * _margin, 46);
    startBtn.titleLabel.font = kFontSizeBig;
    startBtn.enabled = NO;
    [self.view addSubview:startBtn];
    _startBtn = startBtn;
    
    UILabel *startTips = [[UILabel alloc]initWithFrame:CGRectMake(_margin, SCREEN_HEIGHT - 64 -48- 36, SCREEN_WIDTH - 2* _margin, 36)];
    startTips.font = kFontSizeNormal;
    startTips.textAlignment = NSTextAlignmentCenter;
    startTips.text = @"Tips:拖动图片可以排序哦（图片会裁剪成正方形）";
    startTips.textColor = UIColorFromRGB(BABYCOLOR_comment_text);
    [self.view addSubview:startTips];
}

- (void)startMakeVideo
{
    [_startBtn setWorking:YES];
    if (_mMediaObject != nil) {
        if (!_hasSavedDraft)
            [_mMediaObject deleteObject];
        _mMediaObject = nil;
    }
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD showProgress:0 status:@"生成视频中"];
    
    [self setOutputDirectory];
    [self copyFileAndScale];
    [self startEncodeVideo];
    [_startBtn setWorking:NO];
}

- (void)setOutputDirectory
{
    int64_t date = [[NSDate date] timeIntervalSince1970]*1000*1000;
    int random = arc4random();
    if (random < 0) {
        random = -random;
    }
    _key = [NSString stringWithFormat:@"%lld_%d", date, random];
    DLog(@"key : %@", _key);
    
    NSString *tempPath = [BabyFileManager createVideoFolderIfNotExist:_key];
    DLog(@"tempPath : %@", tempPath);
    
    self.mMediaObject = [MediaObject initWithKey:_key path:tempPath];
    DLog(@"self.mMediaObject max : %d", self.mMediaObject.mMaxDuration);
}

/**
 *  _selectPhotos 里面是UIImage 可以直接scale and save
 */
- (void)copyFileAndScale
{

    DLogE(@"_selectedPhotos : %@", _selectedPhotos);
    
    _imageCount = (int)[_selectedPhotos count];
    
    [self scaleAndSaveUIImage];

//    __block VideoImportImageViewController *wSelf = self;
//    [[TZImageManager manager]copyFilesFromAsset:_selectedPhotos Complete:^(NSMutableArray *filePaths, NSMutableArray *fileNames) {
//        wSelf.filePaths = filePaths;
//        DLogE(@"wSelf.filePaths : %@", wSelf.filePaths);
//        [wSelf scaleAndSaveImage];
//    }];
    
}

- (void)scaleAndSaveImage
{
    _imageCount = (int)[_filePaths count];
    
    int duration = 6;
    switch (_imageCount) {
        case 3:
            duration = 6;
            break;
        case 4:
            duration = 8;
            break;
        case 5:
            duration = 11;
            break;
            
        default:
            duration = 6;
            break;
    }
    
    NSString *imageOutPutDir = [_mMediaObject.mOutputDirectory stringByAppendingPathComponent:_key];
    
    _mMediaPart = [_mMediaObject buildMediaPart:imageOutPutDir duration:duration * 1000 type:MEDIA_PART_TYPE_IMPORT_IMAGE tempCount:_imageCount];
    
    _mMediaPart.tempPath = [BabyFileManager createFolderIfNotExist:_mMediaPart.tempPath];
    
    for (int i = 0; i < _imageCount; i++) {
        NSString *filePath = [_filePaths objectAtIndex:i];
        UIImage *image = [ImageUtils handleImage:[UIImage imageWithContentsOfFile:filePath] withSize:CGSizeMake(480, 480)];
        NSString *fileDir = [[[_mMediaPart.tempPath stringByAppendingPathComponent:_mMediaObject.mKey] stringByAppendingString:[NSString stringWithFormat:@"%d",i]] stringByAppendingString:@".jpg"];
        DLogE(@"fileDir : %@", fileDir);
        [[BabyFileManager manager]saveUIImageToPath:fileDir withImage:image];
        
    }
}

- (void)scaleAndSaveUIImage
{
    _imageCount = (int)[_selectedPhotos count];
    
    int duration = 6;
    switch (_imageCount) {
        case 3:
            duration = 6;
            break;
        case 4:
            duration = 8;
            break;
        case 5:
            duration = 11;
            break;
            
        default:
            duration = 6;
            break;
    }
    
    NSString *imageOutPutDir = [_mMediaObject.mOutputDirectory stringByAppendingPathComponent:_key];
    
    _mMediaPart = [_mMediaObject buildMediaPart:imageOutPutDir duration:duration * 1000 type:MEDIA_PART_TYPE_IMPORT_IMAGE tempCount:_imageCount];
    
    _mMediaPart.tempPath = [BabyFileManager createFolderIfNotExist:_mMediaPart.tempPath];
    
    for (int i = 0; i < _imageCount; i++) {
        UIImage *image = [ImageUtils handleImage:[_selectedPhotos objectAtIndex:i] withSize:CGSizeMake(480, 480)];
        NSString *fileDir = [[[_mMediaPart.tempPath stringByAppendingPathComponent:_mMediaObject.mKey] stringByAppendingString:[NSString stringWithFormat:@"%d",i]] stringByAppendingString:@".jpg"];
        DLogE(@"fileDir : %@", fileDir);
        [[BabyFileManager manager]saveUIImageToPath:fileDir withImage:image];
        [_imagePaths addObject:fileDir];
        
    }
}

- (void)startEncodeVideo
{
    __block VideoImportImageViewController *blockSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 生成视频
        
        BOOL hasAudio = YES;
        // 背景音乐
        NSString *music_bg = [_mThemeCommonPath stringByAppendingPathComponent:@"music_bg.mp3"];
        if(![[Utils utils] isFileExists:music_bg])
            hasAudio = NO;
        
        VideoEncoder *encoder = [VideoEncoder videoEncoder];
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc]init];
        
        [mutableArray addObject:@"ffmpeg"];
        [mutableArray addObject:@"-y"];
        
        for (int i=0; i < _imageCount; i++) {
            [mutableArray addObject:@"-loop"];
            [mutableArray addObject:@"1"];
            [mutableArray addObject:@"-i"];
            [mutableArray addObject:[_imagePaths objectAtIndex:i]];
        }
        
        if (hasAudio) {
            [mutableArray addObject:@"-i"];
            [mutableArray addObject:music_bg];
        }
        
        [mutableArray addObject:@"-filter_complex"];
        
        NSString *filters = [[NSString alloc]init];
        for (int j = 0; j < _imageCount; j++) {
            if(j == 0){
                filters = [filters stringByAppendingString:@"[0:v]boxblur=luma_radius=min(h\\,w)/20:luma_power=1:chroma_radius=min(cw\\,ch)/20:chroma_power=1[bg];[bg][0:v]blend=all_expr='A*(if(gte(T,1),1,(1-T)))+B*(1-(if(gte(T,1),1,(1-T))))':enable='between(t,0,1)'[temp0];[temp0][0:v]overlay=0:0:enable='between(t,1,2)'[temp1];"];
            } else if(j == 1){
                filters = [filters stringByAppendingString:@"[temp1][1:v]blend=all_expr='A*(if(gte(T,3),1,(3-T)))+B*(1-(if(gte(T,3),1,(3-T))))':enable='between(t,2,3)'[temp2];[temp2][1:v]overlay=0:0:enable='between(t,3,4)'[temp3];"];
            } else if(j == 2){
                filters = [filters stringByAppendingString:@"[temp3][2:v]blend=all_expr='A*(if(gte(T,5),1,(5-T)))+B*(1-(if(gte(T,5),1,(5-T))))':enable='between(t,4,5)'[temp4];[temp4][2:v]overlay=0:0:enable='between(t,5,6)'"];
            }else if(j == 3){
                filters = [filters stringByAppendingString:@"[temp5];[temp5][3:v]blend=all_expr='A*(if(gte(T,7),1,(7-T)))+B*(1-(if(gte(T,7),1,(7-T))))':enable='between(t,6,7)'[temp6];[temp6][3:v]overlay=0:0:enable='between(t,7,8)'"];
            } else if(j == 4) {
                filters = [filters stringByAppendingString:@"[temp7];[temp7][4:v]blend=all_expr='A*(if(gte(T,9),1,(9-T)))+B*(1-(if(gte(T,9),1,(9-T))))':enable='between(t,8,9)'[temp8];[temp8][4:v]overlay=0:0:enable='between(t,9,11)'"];
            }
        }
        
        [mutableArray addObject:filters];
        [mutableArray addObject:@"-c:a"];
        [mutableArray addObject:@"libfaac"];
        [mutableArray addObject:@"-strict"];
        [mutableArray addObject:@"-2"];
        [mutableArray addObject:@"-c:v"];
        [mutableArray addObject:@"libx264"];
        [mutableArray addObject:@"-s"];
        [mutableArray addObject:@"480x480"];
        [mutableArray addObject:@"-t"];
        [mutableArray addObject:[NSString stringWithFormat:@"%d", _mMediaPart.duration / 1000]];
        [mutableArray addObject:@"-pix_fmt"];
        [mutableArray addObject:@"yuv420p"];
        [mutableArray addObject:@"-r"];
        [mutableArray addObject:@"25"];
        
        [mutableArray addObject:_mMediaPart.mediaPath];
        
        NSArray *array =[mutableArray copy];
        
        OnEncoderProgressBlock progressBlock = ^(long size, long timestamp) {
            float progress = (double)timestamp / ([blockSelf.mMediaPart getDuration] * 1000);
            DLog(@"执行中：size = %ld, timestamp = %ld -> 执行进度 ：%.2f", size, timestamp, progress);
            //通知主线程刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                //回调或者说是通知主线程刷新，
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                [SVProgressHUD showProgress:progress status:@"生成视频中"];
                
            });
        };
        
        OnEncoderCompletionBlock block = ^(int ret, NSString* retString) {
            DLog(@"执行完毕：ret = %d, retString : %@", ret, retString);
            //通知主线程刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                //回调或者说是通知主线程刷新，
                [blockSelf mergeVideoFiles];
                
            });
            
        };
        
        [encoder videoMerge:array progress:progressBlock completion:block];
    });

}

- (void)mergeVideoFiles
{
    
    
    __block VideoImportImageViewController *blockSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *concatPath = [BabyFileManager getVideoMergeFilePathString:blockSelf.mMediaObject.mOutputDirectory concatText:[self.mMediaObject getConcatYUV]];
        DLog(@"concatPath : %@", concatPath);
        
        VideoEncoder *encoder = [VideoEncoder videoEncoder];
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc]init];
        
        [mutableArray addObject:@"ffmpeg"];
        [mutableArray addObject:@"-y"];
        [mutableArray addObject:@"-f"];
        [mutableArray addObject:@"concat"];
        [mutableArray addObject:@"-i"];
        [mutableArray addObject:concatPath];
        [mutableArray addObject:@"-strict"];
        [mutableArray addObject:@"-2"];
        [mutableArray addObject:@"-c"];
        [mutableArray addObject:@"copy"];
        [mutableArray addObject:@"-absf"];
        [mutableArray addObject:@"aac_adtstoasc"];
        [mutableArray addObject:@"-movflags"];
        [mutableArray addObject:@"+faststart"];
        [mutableArray addObject:[self.mMediaObject getOutputTempVideoPath]];
        
        
        NSArray *array =[mutableArray copy];
        
        OnEncoderProgressBlock progressBlock = ^(long size, long timestamp) {
            DLog(@"执行中：size = %ld, timestamp = %ld -> 执行进度 ：%.2f", size, timestamp, (double)timestamp / ([blockSelf.mMediaObject getDuration] * 1000));
        };
        
        OnEncoderCompletionBlock block = ^(int ret, NSString* retString) {
            DLog(@"执行完毕：ret = %d, retString : %@", ret, retString);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //回调或者说是通知主线程刷新，
                [blockSelf pushVideoPreview];
                [SVProgressHUD dismiss];
                
            });
        };
        
        [encoder videoMerge:array progress:progressBlock completion:block];
        
    });
 
}

- (void)pushVideoPreview
{
    VideoPreviewViewController *player = [[VideoPreviewViewController alloc]initWithMediaObject:self.mMediaObject];
    player.tag = _tag;
    player.tag_id = _tag_id;
    player.fromDraft = NO;
    player.outputHeight = 480;
    
    player.savedDraft = ^(BOOL saved) {
        _hasSavedDraft = saved;
    };
    
    player.onPublish = ^() {
        if (self.onPublish) {
            self.onPublish();
        }
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    [self.navigationController pushViewController:player animated:YES];
}


#pragma mark UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _selectedPhotos.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CellImportImage *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CellImportImage class]) forIndexPath:indexPath];
    if (indexPath.row == _selectedPhotos.count) {
        if ([_selectedPhotos count] < IMAGE_COUNT_MAX) {
            cell.imageView.image = [UIImage imageNamed:@"photoAddBtnHL"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"photoAddBtn"];
        }
        
        cell.deleteBtn.hidden = YES;
    } else {
        cell.imageView.image = _selectedPhotos[indexPath.row];
        cell.deleteBtn.hidden = NO;
    }
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _selectedPhotos.count  && [_selectedPhotos count] < IMAGE_COUNT_MAX) { [self pickPhotoButtonClick:nil];}
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath didMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.item >= _selectedPhotos.count || destinationIndexPath.item >= _selectedPhotos.count) return;
    UIImage *image = _selectedPhotos[sourceIndexPath.item];
    if (image) {
        [_selectedPhotos removeObjectAtIndex:sourceIndexPath.item];
        [_selectedPhotos insertObject:image atIndex:destinationIndexPath.item];
        [_collectionView reloadData];
    }
}

#pragma mark Click Event

- (void)deleteBtnClik:(UIButton *)sender {
    [_selectedPhotos removeObjectAtIndex:sender.tag];
    [_selectedAssets removeObjectAtIndex:sender.tag];
    _layout.itemCount = _selectedPhotos.count;
    
    [_collectionView performBatchUpdates:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
        [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        [_collectionView reloadData];
    }];
    
    [self updateStartBtn];
}

- (void)pickPhotoButtonClick:(UIButton *)sender {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:IMAGE_COUNT_MAX delegate:self];
    imagePickerVc.selectedAssets = _selectedAssets; // optional, 可选的
     imagePickerVc.allowPickingVideo = NO;
     imagePickerVc.allowPickingImage = YES;
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark TZImagePickerControllerDelegate

/// User click cancel button
/// 用户点击了取消
- (void)imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    // NSLog(@"cancel");
}

/// User finish picking photo，if assets are not empty, user picking original photo.
/// 用户选择好了图片，如果assets非空，则用户选择了原图。
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets {
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    _layout.itemCount = _selectedPhotos.count;
    [_collectionView reloadData];
    _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
    
    [self updateStartBtn];
    
}

- (void)updateStartBtn
{
    if ([_selectedPhotos count] >= IMAGE_COUNT_MIN) {
        self.startBtn.enabled = YES;
    } else {
        self.startBtn.enabled = NO;
    }
}

@end
