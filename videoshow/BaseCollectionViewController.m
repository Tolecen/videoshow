//
//  BaseCollectionViewController.m
//  videoshow
//
//  Created by gutou on 2017/2/27.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "BaseCollectionViewController.h"

@interface BaseCollectionViewController ()


@end

@implementation BaseCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (UICollectionViewFlowLayout *) flowLayout
{
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    return layout;
}


- (Class)collectionViewCellClass{
    return [UICollectionViewCell class];
}

- (NSString *)collectionCellIdentifier{
    return @"collectionCell";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = [self flowLayout];
    
    _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.collectionView registerClass:[self collectionViewCellClass] forCellWithReuseIdentifier:[self collectionCellIdentifier]];

    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.allowsSelection = YES;
    
    [self.view addSubview:self.collectionView];
    
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    if ([self shouldShowRefresh]) {
        
        [self beginRefreshing];
        
        // 下拉刷新
        self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            
            [self requestRefresh];
        }];
    }
    if ([self shouldShowGetMore]) {
        
        self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            
            [self requestGetMore];
        }];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    NSLog(@"子类需要重写%s",__FUNCTION__);
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"子类需要重写%s",__FUNCTION__);
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSLog(@"子类需要重写%s",__FUNCTION__);
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

- (void) reloadData;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

- (BOOL)shouldShowRefresh
{
    return YES;
}

- (BOOL)shouldShowGetMore
{
    return NO;
}

-(void)finishRequest
{
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
}

//立刻刷新  可用于进入页面立即刷新
- (void) beginRefreshing;
{
    [self.collectionView.mj_header beginRefreshing];
}

- (void)requestRefresh
{
    NSLog(@"子类需要重写%s",__FUNCTION__);
}

- (void)requestGetMore
{
    NSLog(@"子类需要重写%s",__FUNCTION__);
}



- (BOOL) shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


@end
