//
//  lz_VideoTemplateListVC.m
//  videoshow
//
//  Created by gutou on 2017/3/1.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "lz_VideoTemplateListVC.h"
#import "VideoDetailCell_1.h"

#import "lz_VideoTemplateModel.h"

@interface lz_VideoTemplateListVC ()

@property (nonatomic, strong) NSArray *listDatas;

@end

@implementation lz_VideoTemplateListVC

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self requestRefresh];
}

- (UICollectionViewFlowLayout *) flowLayout
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 3;
    layout.minimumInteritemSpacing = 3;
    layout.itemSize = CGSizeMake((MainScreenSize.width-6)/2, 170);
    
    return layout;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.directionalLockEnabled = YES;
    
    self.collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    [self.collectionView registerClass:[VideoDetailCell_1 class] forCellWithReuseIdentifier:NSStringFromClass([VideoDetailCell_1 class])];
    
    self.listDatas = [NSArray array];
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    NSLog(@"self.listDatas = %@",self.listDatas);
    return self.listDatas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    VideoDetailCell_1 *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([VideoDetailCell_1 class]) forIndexPath:indexPath];
    cell.model = self.listDatas[indexPath.item];
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VideoDetailCell_1 *cell = (VideoDetailCell_1 *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (self.didSelectBlock) {
        self.didSelectBlock(@{@"model":cell.model});
    }
}

- (void) setDatas:(NSArray *)datas
{
    _datas = datas;
}

- (void) requestGetMore
{
    [self finishRequest];
}

- (void) requestRefresh
{
    [self HudShowWithStatus:@"正在加载"];
    [lz_VideoTemplateModel requestWithStyleId:self.datas[0]
                                     isCharge:self.datas[1]
                                    shortTime:self.datas[2]
                                    pageIndex:self.datas[3]
                                       length:self.datas[4]
                                SuccessHandle:^(id responseObject) {
                                    
                                    self.listDatas = [NSArray arrayWithArray:responseObject];
                                    if (!((NSArray *)responseObject).count) {
                                        [self ShowWhenBadNetworkWithImage:[UIImage imageNamed:@"noJiaZai"] content:@"没有数据"];
                                    }
                                    [self reloadData];
                                    [self finishRequest];
                                    [self HudHide];
                                } FailureHandle:^(NSError *error) {
                                    [self HudShowWithStatus:@"加载失败"];
                                }];

}

@end
