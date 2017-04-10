//
//  UIImageView+YYImageBrowser.m
//  PogoShow
//
//  Created by yan ruichen on 14-8-18.
//  Copyright (c) 2014年 mRocker. All rights reserved.
//

#import "UIImageView+YYImageBrowser.h"
#import "UIImageView+AFNetworking.h"


@interface UIImageViewBrowserExtensions : NSObject <UIScrollViewDelegate>
{
    @package
    ImageViewBlock _longPressBlock;
    ImageViewBlock _browserLongPressBlock;
    
    __weak UIImageView* _imageView;
    __block NSMutableArray *_bigImages;
    
    //realImageView 将加在ScrollView上
    UIImageView* _realImageView;
    UIImageView * _real2ImageView;
    UIScrollView* _backgroundScrollView;
    
    UITapGestureRecognizer* _tap;
    UILongPressGestureRecognizer* _longPress;
    
    NSURL* _realImageURL;
    __weak UIView* _addToView;
}

@property(readwrite ,nonatomic)BOOL browseEnabled;

@property (nonatomic, strong) NSMutableArray *bigImages;

@property(strong, nonatomic)UIColor *backgroundColor;

@property(strong, nonatomic)NSURL* realImageURL;

@property(weak, nonatomic)UIView* addToView;

@property(strong, nonatomic)UIActivityIndicatorView* spinner;


-(void)showAnimated:(BOOL)animated;
-(void)hideAnimated:(BOOL)animated;

-(void)setLongPressBlock:(ImageViewBlock)longPressBlock;

@end

@implementation UIImageViewBrowserExtensions

- (void)dealloc
{
    [_imageView removeGestureRecognizer:_tap];
    [_imageView removeGestureRecognizer:_longPress];
}

-(void)setupViews {
    _backgroundScrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _backgroundScrollView.backgroundColor = [UIColor blackColor];
    _backgroundScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _backgroundScrollView.pagingEnabled = YES;
    _backgroundScrollView.delegate = self;
    _backgroundScrollView.bouncesZoom = YES;
    _backgroundScrollView.minimumZoomScale = 1;
    _backgroundScrollView.maximumZoomScale = 3;
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollSingleTapped:)];
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollDoubleTapped:)];
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(scrollLongPressed:)];
    [singleTap setNumberOfTapsRequired:1];
    [doubleTap setNumberOfTapsRequired:2];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [_backgroundScrollView addGestureRecognizer:singleTap];
    [_backgroundScrollView addGestureRecognizer:doubleTap];
    [_backgroundScrollView addGestureRecognizer:longPress];
    [_backgroundScrollView setScrollEnabled:YES];
    
    _realImageView = [[UIImageView alloc] init];
    _realImageView.contentMode = UIViewContentModeScaleAspectFill;
    _realImageView.clipsToBounds = YES;
    
    _real2ImageView = [[UIImageView alloc] init];
    _real2ImageView.contentMode = UIViewContentModeScaleAspectFill;
    _real2ImageView.clipsToBounds = YES;
}

-(UIActivityIndicatorView *)spinner
{
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return _spinner;
}

#pragma mark - actions

-(void)showSpinner {
    UIView* bgView = _backgroundScrollView.superview;
    self.spinner.center = CGPointMake(bgView.bounds.size.width/2, bgView.bounds.size.height/2);
    [bgView addSubview:self.spinner];
    [self.spinner startAnimating];
}

-(void)hideSpinner {
    [self.spinner stopAnimating];
    [self.spinner removeFromSuperview];
}

-(void)loadRealImage {
    if (_realImageURL) {
        __weak typeof(_realImageView) weakRealImageView = _realImageView;
        __weak typeof(self) weakSelf = self;
        [self showSpinner];
        
        [_realImageView sd_setImageWithURL:_realImageURL placeholderImage:_imageView.image completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            
            if (image) {
                weakRealImageView.image = image;
                [weakSelf hideSpinner];
            }else{
                [weakSelf hideSpinner];
            }
        }];
    }
}

-(void)showAnimated:(BOOL)animated {
    UIView* addToView = [self addToView];
    
    if (!_backgroundScrollView) {
        [self setupViews];
    }
    
    _backgroundScrollView.alpha = 0;
    _backgroundScrollView.frame = addToView.bounds;
    _backgroundScrollView.contentSize = CGSizeMake(addToView.bounds.size.width, 0);
    [addToView addSubview:_backgroundScrollView];
    
    _realImageView.image = _imageView.image;
    _realImageView.frame = [self frameOfTheImageViewFromAddToView];
    [addToView addSubview:_realImageView];
    
    CGSize imageScreenSize = (CGSize){addToView.bounds.size.width, _realImageView.image.size.height/_realImageView.image.size.width * addToView.bounds.size.width};
    _backgroundScrollView.contentInset = UIEdgeInsetsMake((addToView.bounds.size.height - imageScreenSize.height)/2, 0, 0, 0);
    
    [UIView animateWithDuration:.23 animations:^{
        _backgroundScrollView.alpha = 1;
        _realImageView.frame = (CGRect){{0,_backgroundScrollView.contentInset.top},imageScreenSize};
    } completion:^(BOOL finished) {
        [self moveView:_realImageView toView:_backgroundScrollView];
        [self loadRealImage];
    }];
}

-(void)hideAnimated:(BOOL)animated {
    UIView* addToView = [self addToView];

    _backgroundScrollView.zoomScale = 1;
    
    [_realImageView cancelImageDownloadTask];
    
    [self hideSpinner];
    
    [self moveView:_realImageView toView:addToView];
    
    [UIView animateWithDuration:.23 animations:^{
        _backgroundScrollView.alpha = 0;
        _realImageView.frame = [self frameOfTheImageViewFromAddToView];
    } completion:^(BOOL finished) {
        [_realImageView removeFromSuperview];
        [_backgroundScrollView removeFromSuperview];
    }];
    
}

-(void)imageTapped:(UITapGestureRecognizer*)tap {
    [self showAnimated:YES];
}

-(void)scrollSingleTapped:(UITapGestureRecognizer*)tap {
    [self hideAnimated:YES];
}

-(void)scrollDoubleTapped:(UITapGestureRecognizer*)tap {
    if (_backgroundScrollView.zoomScale < 1.3) {
        CGPoint pt = [tap locationInView:tap.view];
        [_backgroundScrollView zoomToRect:[self rectFromPoint:pt width:50] animated:YES];
    } else {
        [_backgroundScrollView setZoomScale:1 animated:YES];
    }
}

-(void)scrollLongPressed:(UILongPressGestureRecognizer*)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        if (_browserLongPressBlock) {
            _browserLongPressBlock(_realImageView);
        }
    }
}

-(void)longPressAction:(UILongPressGestureRecognizer*)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        if (_longPressBlock) {
            _longPressBlock(_imageView);
        };
    }
    
}

#pragma mark - getter actions

-(CGRect)frameOfTheImageViewFromAddToView {
    return [_imageView.superview convertRect:_imageView.frame toView:self.addToView];
}

#pragma mark - getters
-(UIColor *)backgroundColor
{
    return _backgroundScrollView.backgroundColor;
}

-(UIView *)addToView
{
    return _addToView?_addToView:[UIApplication sharedApplication].keyWindow;
}

#pragma mark - setters
-(void)setLongPressBlock:(ImageViewBlock)longPressBlock
{
    _longPressBlock = longPressBlock;
    [_imageView removeGestureRecognizer:_longPress];
    if (_longPressBlock) {
        if (!_longPress) {
            _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        }
        [_imageView addGestureRecognizer:_longPress];
    }
    
}

-(void)setBrowserLongPressHandler:(ImageViewBlock)longPressBlock {
    _browserLongPressBlock = longPressBlock;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundScrollView.backgroundColor = backgroundColor;
}

-(void)setImageView:(UIImageView *)imageView
{
    [_imageView removeGestureRecognizer:_tap];
    _imageView = imageView;
    
    [self setBrowseEnabled:_browseEnabled];
}

-(void)setBrowseEnabled:(BOOL)browseEnabled
{
    _browseEnabled = browseEnabled;
    if (_browseEnabled) {
        if (!_tap) {
            _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
        }
        [_imageView addGestureRecognizer:_tap];
    } else {
        [_imageView removeGestureRecognizer:_tap];
    }
}

#pragma mark - tool methods
-(CGRect)rectFromPoint:(CGPoint)pt width:(CGFloat)width {
    CGFloat w = width/2;
    CGRect rect = CGRectMake(pt.x - w, pt.y - w, width, width);
    return rect;
}

-(void)moveView:(UIView*)view toView:(UIView*)toView {
    CGRect rect = [view.superview convertRect:view.frame toView:toView];
    view.frame = rect;
    [toView addSubview:view];
}

-(UIEdgeInsets)contentInsetsFromSize:(CGSize)size forView:(UIView*)view {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    if (view.bounds.size.height > size.height) {
        contentInsets.top = (view.bounds.size.height - size.height) / 2;
        return contentInsets;
    } else {
        return contentInsets;
    }
}

#pragma mark - scrollView delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _realImageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    
    [UIView animateWithDuration:.15 animations:^{
        
        scrollView.contentInset = [self contentInsetsFromSize:CGSizeMake(view.frame.size.width, view.frame.size.height) forView:scrollView];
        
    } completion:^(BOOL finished) {
        
    }];
}

@end



#import <objc/runtime.h>
static char UIImageViewImageBorwser;
@implementation UIImageView (YYImageBrowser)

#pragma mark - dynamic property
- (UIImageViewBrowserExtensions *)extension {
    UIImageViewBrowserExtensions* obj = objc_getAssociatedObject(self, &UIImageViewImageBorwser);
    if (!obj) {
        obj = [[UIImageViewBrowserExtensions alloc] init];
        obj.imageView = self;
        self.userInteractionEnabled = YES;
        objc_setAssociatedObject(self, &UIImageViewImageBorwser, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return obj;
}

#pragma mark - package properties
#pragma mark -
-(void)setBrowseEnabled:(BOOL)browseEnabled
{
    [self extension].browseEnabled = browseEnabled;
}

-(BOOL)browseEnabled
{
    return [self extension].browseEnabled;
}

#pragma mark -
-(void)setBrowserBackgroundColor:(UIColor *)browseBackgroundColor
{
    [[self extension] setBackgroundColor:browseBackgroundColor];
}

-(UIColor *)browserBackgroundColor
{
    return [self extension]->_backgroundScrollView.backgroundColor;
}

#pragma mark -
-(void)setRealImageURL:(NSURL *)realImageURL
{
    [[self extension] setRealImageURL:realImageURL];
}

-(NSURL *)realImageURL
{
    return [self extension]->_realImageURL;
}
//lz
- (void) setBigImages:(NSMutableArray *)bigImages
{
    [[self extension] setBigImages:bigImages];
}
- (NSMutableArray *) bigImages
{
    if (![self extension] -> _bigImages.count) {
        return [NSMutableArray arrayWithObjects:@"countIsOne", nil];
    }
    return [self extension] -> _bigImages;
}

#pragma mark - package setter actions
-(void)setImageLongPressHandler:(ImageViewBlock)longPressBlock
{
    [[self extension] setLongPressBlock:longPressBlock];
}

-(void)setBrowserLongPressHandler:(ImageViewBlock)longPressBlock
{
    [[self extension] setBrowserLongPressHandler:longPressBlock];
}


#pragma mark - package actions
-(void)showAnimated:(BOOL)animated {
    [[self extension] showAnimated:animated];
}

-(void)hideAnimated:(BOOL)animated {
    [[self extension] hideAnimated:animated];
}

-(void)setAddToView:(UIView *)addToView
{
    [[self extension] setAddToView:addToView];
}

-(UIView *)addToView
{
    return [self extension]->_addToView;
}

@end
