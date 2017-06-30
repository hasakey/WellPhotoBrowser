//
//  PhotoBrowser.m
//  WellPhotoBrowser
//
//  Created by 同筑科技 on 2017/6/30.
//  Copyright © 2017年 well. All rights reserved.
//


#import "PhotoBrowser.h"

@interface PhotoBrowser ()<UIScrollViewDelegate>


@property (nonatomic,strong) UIScrollView *backgroundScrollView;

///  背景view
@property (nonatomic,strong) UIView *blackBackgroundView;

/**
 *  原始frame数组
 */
@property (nonatomic,strong) NSMutableArray *originRects;

/**
 *  存放图片的数组
 */
@property (nonatomic,strong) NSMutableArray *photos;

@end

@implementation PhotoBrowser

+(instancetype)photoBrowser
{
    return [[PhotoBrowser alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.blackBackgroundView];
        [self addSubview:self.backgroundScrollView];
    }
    return self;
}



-(void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    //获得原来的frame
//    [self setupOriginRects];
    //设置scrollView
    self.backgroundScrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * self.photos.count, 0);
    self.backgroundScrollView.contentOffset = CGPointMake([UIScreen mainScreen].bounds.size.width * self.currentIndex, 0);
    
    //创建子视图
    [self setUpSubViews];
}
#pragma mark    创建子视图
-(void)setUpSubViews
{
//    __weak typeof(self) weakSelf = self;
    for (int i = 0; i < self.photos.count; i++) {
        UIScrollView *imgScorllView = [self setUpImgScrollView:i];
        UIImageView *img = self.photos[i];
        
        UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTapAction:)];
        [img addGestureRecognizer:oneTap];
        
        UITapGestureRecognizer *twoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twoTapAction:)];
        twoTap.numberOfTapsRequired = 2;
        [img addGestureRecognizer:twoTap];
        
        //zonmTap失败了再执行photoTap，否则zonmTap永远不会被执行
        [oneTap requireGestureRecognizerToFail:twoTap];
        
        [imgScorllView addSubview:img];
        img.frame = [self.originRects[i] CGRectValue];
        [UIView animateWithDuration:0.3 animations:^{
            
            [self setUpImage:img];
        }];
    }
}
#pragma mark    照片点一次退出浏览器
-(void)oneTapAction:(UIGestureRecognizer *)oneTap
{
    UIImageView *image = (UIImageView *)oneTap.view;
    UIScrollView *imageScrollView = (UIScrollView *)image.superview;
    imageScrollView.zoomScale = 1.0;
    
    if (CGRectGetHeight(image.frame) > [UIScreen mainScreen].bounds.size.height) {
        imageScrollView.contentOffset = CGPointMake(0, 0);
    }
    
    CGRect frame = [self.originRects[image.tag] CGRectValue];
    
    [UIView animateWithDuration:0.3 animations:^{
        image.frame = frame;
        self.blackBackgroundView.alpha = 0;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];

    }];
}

#pragma mark    照片点两次放大
-(void)twoTapAction:(UIGestureRecognizer *)twoTap
{
    [UIView animateWithDuration:0.3 animations:^{
        UIScrollView *imageScrollView = (UIScrollView *)twoTap.view.superview;
        imageScrollView.zoomScale = 3.0;
    }];
}

#pragma mark    设置每一张图片的frame
-(void)setUpImage:(UIImageView *)image
{
    UIScrollView *imgScrollView = (UIScrollView *)image.superview;
    self.blackBackgroundView.alpha = 1.0;
    
    //长宽比例
    CGFloat ratio = (double)image.image.size.height/(double)image.image.size.width;
    CGFloat imgW = [UIScreen mainScreen].bounds.size.width;
    CGFloat imgH = [UIScreen mainScreen].bounds.size.height * ratio;
    if (imgH < [UIScreen mainScreen].bounds.size.height) {
        image.bounds = CGRectMake(0, 0, imgW, imgH);
        image.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 0.5);
    }else
    {
        image.frame = CGRectMake(0, 0, imgW, imgH);
        imgScrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, imgH);
    }
}
#pragma mark    每一张图是加载每一个scrollView上的
-(UIScrollView *)setUpImgScrollView:(int)tag
{

    UIScrollView *imgScrollView = [UIScrollView new];
    imgScrollView.backgroundColor = [UIColor clearColor];
    imgScrollView.tag = tag;
    imgScrollView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width * tag, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    imgScrollView.delegate = self;
    imgScrollView.minimumZoomScale = 1;
    imgScrollView.maximumZoomScale = 3;
    imgScrollView.showsVerticalScrollIndicator = NO;
    imgScrollView.showsHorizontalScrollIndicator = NO;
    [self.backgroundScrollView addSubview:imgScrollView];
    return imgScrollView;
}
#pragma mark 获取原始frame
-(void)setupOriginRects{
    for (UIImageView *img in self.photos) {
        CGRect originRect = [[UIApplication sharedApplication].keyWindow convertRect:img.frame fromView:img.superview];
        [self.originRects addObject:[NSValue valueWithCGRect:originRect]];
    }

    
}

#pragma mark UIScrollViewDelegate

//告诉scrollview要缩放的是哪个子控件
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (scrollView.tag == 101) {
        return nil;
    }
    
    UIImageView *image = self.photos[scrollView.tag];
    return image;

}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    if (scrollView.tag == 101) {
        return ;
    }
    
    UIImageView *image = (UIImageView *)self.photos[scrollView.tag];
    CGFloat imageY = ([UIScreen mainScreen].bounds.size.height - image.frame.size.height) *
    0.5;
    CGRect imageFrame = image.frame;
    
    if (imageY > 0) {
        imageFrame.origin.y = imageY;
    }else
    {
        imageFrame.origin.y = 0;
    }
    
    image.frame = imageFrame;
    
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    
    //如果结束缩放后scale为1时，跟原来的宽高会有些轻微的出入，导致无法滑动，需要将其调整为原来的宽度
    if (scale == 1.0) {
        CGSize tempSize = scrollView.contentSize;
        tempSize.width = [UIScreen mainScreen].bounds.size.width;
        scrollView.contentSize = tempSize;
        CGRect tempFrame = view.frame;
        tempFrame.size.width = [UIScreen mainScreen].bounds.size.width;
        view.frame = tempFrame;
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    int currentIndex = scrollView.contentOffset.x/[UIScreen mainScreen].bounds.size.width;
    if (self.currentIndex !=currentIndex && scrollView.tag == 101) {
        self.currentIndex = currentIndex;
        for (UIView *view in scrollView.subviews) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scrollView = (UIScrollView *)view;
                scrollView.zoomScale = 1.0f;
            }
        }
    }
    
}


#pragma mark    懒加载
-(UIView *)blackBackgroundView
{
    if (!_blackBackgroundView) {
        _blackBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _blackBackgroundView.backgroundColor = [UIColor blackColor];
    }
    return _blackBackgroundView;
}

-(UIScrollView *)backgroundScrollView
{
    if (!_backgroundScrollView) {
        _backgroundScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _backgroundScrollView.backgroundColor = [UIColor clearColor];
        _backgroundScrollView.delegate = self;
        _backgroundScrollView.tag = 101;
        _backgroundScrollView.pagingEnabled = YES;
        _backgroundScrollView.bounces = YES;
        _backgroundScrollView.showsVerticalScrollIndicator = NO;
        _backgroundScrollView.showsHorizontalScrollIndicator = NO;
        
    }
    return _backgroundScrollView;
}

-(NSMutableArray *)originRects
{
    if (!_originRects) {
        _originRects = [NSMutableArray array];
    }
    return _originRects;
}


-(NSMutableArray *)photos
{
    if (!_photos) {
        _photos = [NSMutableArray array];
    }
    return _photos;
}


-(void)setOriginalPhoto:(NSMutableArray *)originalPhoto
{
    _originalPhoto = originalPhoto;
    for (UIImageView *img in originalPhoto) {
        CGRect originRect = [[UIApplication sharedApplication].keyWindow convertRect:img.frame fromView:img.superview];
        [self.originRects addObject:[NSValue valueWithCGRect:originRect]];
    }
    
    for (UIImageView *view in originalPhoto) {
        UIImageView *testView = [[UIImageView alloc] init];
        testView.image = view.image;
        testView.frame = view.frame;
        testView.contentMode = UIViewContentModeScaleAspectFill;
        testView.userInteractionEnabled = YES;
        testView.tag = view.tag;
        testView.clipsToBounds = YES;
        [self.photos addObject:testView];
    }
}



@end
