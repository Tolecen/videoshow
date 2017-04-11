//
//  ThemeStoreViewController.m
//  Babypai
//
//  Created by ning on 16/5/19.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "ThemeStoreViewController.h"
#import "VideoThemes.h"
#import "MJRefresh.h"
#import "CellThemeStore.h"
#import "BabyFileDownloadManager.h"
#import "VideoThemeEntity.h"
#import "BabyFileManager.h"
#import "ThemeHelper.h"
#import "SVProgressHUD.h"

@interface ThemeStoreViewController ()<UITableViewDelegate,UITableViewDataSource, BabyFileDownloadManagerDelegate>

@property (nonatomic, strong) VideoThemes *mVideoThemes;
@property (nonatomic, assign) int cursor;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *mVideoThemeEntitys;

@property (nonatomic, strong) NSString *themeDownloadPath;

@end

@implementation ThemeStoreViewController

- (NSString *)title
{
    return @"MV商店";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [BabyFileDownloadManager sharedFileDownloadManager].delegate = self;
    //[MobClick beginLogPageView:[self title]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [BabyFileDownloadManager sharedFileDownloadManager].delegate = nil;
    //[MobClick endLogPageView:[self title]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _cursor = 0;
    
    NSString *mThemeCacheDir = [[BabyFileManager manager] themeDir];
    
    _themeDownloadPath = [mThemeCacheDir stringByAppendingPathComponent:THEME_DOWNLOAD_VIDEO];
    DLogV(@"_themeDownloadPath : %@", _themeDownloadPath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:_themeDownloadPath]){
        [fileManager createDirectoryAtPath:_themeDownloadPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(pressDoneButton)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = UIColorFromRGB(BABYCOLOR_background);
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[CellThemeStore class] forCellReuseIdentifier:NSStringFromClass([CellThemeStore class])];
    [self loadData];
    
}

- (void)initUserInfo
{
    [super initUserInfo];
    [self loadNewDataRefresh];
}

- (void)pressDoneButton
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadData
{
    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=60; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_anim__000%zd", i]];
        [idleImages addObject:image];
    }
    
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=8; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_0%zd", i]];
        [refreshingImages addObject:image];
    }
    
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewDataRefresh)];
    // 设置普通状态的动画图片
    [header setImages:idleImages forState:MJRefreshStateIdle];
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    [header setImages:refreshingImages forState:MJRefreshStatePulling];
    // 设置正在刷新状态的动画图片
    [header setImages:refreshingImages forState:MJRefreshStateRefreshing];
    // 设置header
    
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    
    self.tableView.mj_header = header;
    [self.tableView.mj_header beginRefreshing];
    
    
}

- (void)loadDataMore
{
    _cursor++;
    [self loadNewData];
}

- (void)loadNewDataRefresh
{
    _cursor = 0;
    
    [self loadNewData];
}

- (void)loadNewData
{
    DataCompletionBlock completionBlock = ^(NSDictionary *data, NSString *errorString){
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (data != nil) {
            if (_cursor == 0) {
                _mVideoThemes = nil;
            }
            
            [self processData:data];
        } else {
            
        }
    };
    
    
    BabyDataSource *souce = [BabyDataSource dataSource];
    
    NSString *fields = [NSString stringWithFormat:@"{\"cursor\":\"%d\"}", _cursor];
    
    [souce getData:VIDEO_THEME parameters:fields completion:completionBlock];
}

- (void)processData:(NSDictionary *)data
{
    if(_mVideoThemes == nil) {
        
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadDataMore)];
        [footer setTitle:NOMOREDATA forState:MJRefreshStateNoMoreData];
        self.tableView.mj_footer = footer;
        _mVideoThemes = [VideoThemes mj_objectWithKeyValues:data];
    } else {
        VideoThemes *mVideoThemes = [VideoThemes mj_objectWithKeyValues:data];
        [_mVideoThemes.info addObjectsFromArray:mVideoThemes.info];
        
        if ([mVideoThemes.info count] == 0) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
    }
    
    if ([_mVideoThemes.info count] == 0) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.tableView reloadData];
        if ([_mVideoThemes.info count] < 10) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
    }
    
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _mVideoThemes.info.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_WIDTH / 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BabyFileDownloadManager *downloadManager = [BabyFileDownloadManager sharedFileDownloadManager];
    CellThemeStore *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellThemeStore class])];
    VideoTheme *mVideoTheme = _mVideoThemes.info[indexPath.row];
    
    BOOL success = [self ifCurrentFileDownloadSuccess:mVideoTheme.themeId];
    if(success){
        mVideoTheme.status = FileDownloadStateFinish;
    }
    else{
        mVideoTheme.status = [downloadManager getFileDownloadStateWithFileId:mVideoTheme.themeId];
    }
    
    
    cell.mVideoTheme = mVideoTheme;
    cell.cellIndex = indexPath.row;
    cell.downloadClicked = ^(NSInteger cellIndex, VideoTheme *mVideoTheme){
        DLog(@"downloadClicked----- %ld , mVideoTheme.status : %d", cellIndex, mVideoTheme.status);
        
        switch (mVideoTheme.status) {
            case FileDownloadStateWaiting: {
                [downloadManager addDownloadWithFileId:mVideoTheme.themeId fileUrl:mVideoTheme.themeDownloadUrl directoryPath:_themeDownloadPath fileName:[mVideoTheme.themeDownloadUrl lastPathComponent]];
                mVideoTheme.status = [downloadManager getFileDownloadStateWithFileId:mVideoTheme.themeId];
                [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
//            case FileDownloadStateDownloading: {
//                [downloadManager suspendDownloadWithFileId:mVideoTheme.themeId];
//                break;
//            }
//            case FileDownloadStateSuspending: {
//                [downloadManager recoverDownloadWithFileId:mVideoTheme.themeId];
//                break;
//            }
            case FileDownloadStateFail: {
                //失败的需要重新加入到队列中
                [downloadManager addDownloadWithFileId:mVideoTheme.themeId fileUrl:mVideoTheme.themeDownloadUrl directoryPath:_themeDownloadPath fileName:[mVideoTheme.themeDownloadUrl lastPathComponent]];
                mVideoTheme.status = [downloadManager getFileDownloadStateWithFileId:mVideoTheme.themeId];
                [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                return;
            }
            case FileDownloadStateFinish: {
                
                return;
            }
            default: {
                [downloadManager addDownloadWithFileId:mVideoTheme.themeId fileUrl:mVideoTheme.themeDownloadUrl directoryPath:_themeDownloadPath fileName:[mVideoTheme.themeDownloadUrl lastPathComponent]];
                mVideoTheme.status = [downloadManager getFileDownloadStateWithFileId:mVideoTheme.themeId];
                [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                return;
            }
        }
        
    };
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark --- private method ---

- (BOOL)ifCurrentFileDownloadSuccess:(long)themeId
{
    _mVideoThemeEntitys = [[VideoThemeEntity MR_findAll] mutableCopy];
    
    for(VideoThemeEntity *mVideoThemeEntity in _mVideoThemeEntitys){
        if([mVideoThemeEntity.themeId longValue] == themeId){
            return YES;
        }
    }
    return NO;
}

- (CellThemeStore *)getTargetCellWithFileId:(long)themeId
{
    NSArray *cellArr = _tableView.visibleCells;
    for(id obj in cellArr){
        if([obj isKindOfClass:[CellThemeStore class]]){
            CellThemeStore *downloadCell = (CellThemeStore *)obj;
            if(downloadCell.mVideoTheme.themeId == themeId){
                return downloadCell;
            }
        }
    }
    return nil;
}

- (void)saveIntoEntity:(VideoTheme *)mVideoTheme
{
    
    VideoThemeEntity *themeEntity = [VideoThemeEntity MR_findFirstOrCreateByAttribute:@"themeId" withValue:[NSNumber numberWithLong:mVideoTheme.themeId]];
    
    themeEntity.themeIcon = mVideoTheme.themeIcon;
    themeEntity.themeDisplayName = mVideoTheme.themeDisplayName;
    themeEntity.themeName = mVideoTheme.themeName;
    themeEntity.themeDownloadUrl = mVideoTheme.themeDownloadUrl;
    themeEntity.themeUpdateAt = [NSString stringWithFormat:@"%ld",mVideoTheme.themeUpdateAt];
    themeEntity.isLock = [NSNumber numberWithLong:mVideoTheme.isLock];
    themeEntity.isBuy = [NSNumber numberWithLong:mVideoTheme.isBuy];
    themeEntity.themeId = [NSNumber numberWithLong:mVideoTheme.themeId];
    themeEntity.pic_type = [NSNumber numberWithLong:mVideoTheme.pic_type];
    themeEntity.banner = mVideoTheme.banner;
    themeEntity.themeIcon = mVideoTheme.themeIcon;
    themeEntity.price = [NSNumber numberWithInt:mVideoTheme.price];
    themeEntity.previewVideoPath = mVideoTheme.previewVideoPath;
    themeEntity.themeUrl = mVideoTheme.themeUrl;
    themeEntity.category = mVideoTheme.category;
    themeEntity.themeType = [NSNumber numberWithInt:mVideoTheme.themeType];
    themeEntity.lockType = [NSNumber numberWithInt:mVideoTheme.lockType];
    themeEntity.isMv = [NSNumber numberWithInt:mVideoTheme.isMv];
    themeEntity.isMP4 = [NSNumber numberWithInt:mVideoTheme.isMP4];
    themeEntity.status = [NSNumber numberWithInt:mVideoTheme.status];
    themeEntity.percent = [NSNumber numberWithInt:mVideoTheme.percent];
    
    __block ThemeStoreViewController *wSelf = self;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
        
        [[ThemeHelper helper]parseThemeDownload:[_themeDownloadPath stringByAppendingPathComponent:mVideoTheme.themeUrl]];
        if (wSelf.onThemeDownload) {
            wSelf.onThemeDownload();
        };
        
    }];
    
}


#pragma mark --- delegate ---

- (void)fileDownloadManagerStartDownload:(BabyFileDownload *)download
{
    CellThemeStore *downloadCell = [self getTargetCellWithFileId:download.fileId];
    downloadCell.mVideoTheme.status = FileDownloadStateDownloading;
    [downloadCell setMVideoTheme:downloadCell.mVideoTheme];

}

- (void)fileDownloadManagerProgress:(BabyFileDownload *)download progress:(float)progress
{
    CellThemeStore *downloadCell = [self getTargetCellWithFileId:download.fileId];
    downloadCell.mVideoTheme.status = FileDownloadStateDownloading;
    downloadCell.mVideoTheme.percent = progress;
    [downloadCell setMVideoTheme:downloadCell.mVideoTheme];
}

- (void)fileDownloadManagerFinishDownload:(BabyFileDownload *)download success:(BOOL)downloadSuccess filePath:(NSString *)filePath error:(NSError *)error
{
    DLogV(@"fileDownloadManagerFinishDownload : downloadSuccess : %d, filePath : %@", downloadSuccess, filePath);
    
    CellThemeStore *downloadCell = [self getTargetCellWithFileId:download.fileId];
    
    if ( downloadSuccess ) {
        downloadCell.mVideoTheme.status = FileDownloadStateFinish;
        downloadCell.mVideoTheme.percent = 1;
        downloadCell.mVideoTheme.themeUrl = [filePath lastPathComponent];
        [self saveIntoEntity:downloadCell.mVideoTheme];
    } else {
        downloadCell.mVideoTheme.status = FileDownloadStateFail;
        downloadCell.mVideoTheme.percent = 0;
        
        if (error.code == 3) {
            [SVProgressHUD showErrorWithStatus:@"手机空间不足"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        } else {
            [SVProgressHUD showErrorWithStatus:@"下载失败"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        }
        
    }
    [downloadCell setMVideoTheme:downloadCell.mVideoTheme];
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:downloadCell];
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

@end
