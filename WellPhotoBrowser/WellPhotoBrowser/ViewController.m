//
//  ViewController.m
//  WellPhotoBrowser
//
//  Created by 同筑科技 on 2017/6/30.
//  Copyright © 2017年 well. All rights reserved.
//

#import "ViewController.h"
#import "PhotoBrowser.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ViewController ()

@property(nonatomic,strong)UIView *containerView;

@property(nonatomic,strong)NSMutableArray *imageArray;

@property(nonatomic,strong)NSMutableArray *netImageArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.containerView];
    [self setUpImage];
    
}
-(void)setUpImage
{
    for (int i = 0; i < 9; i ++) {
        int column = i%3;
        int row = i/3;
        CGFloat imgX = column * (80 + 5);
        CGFloat imgY = row * (80 +5);
        self.containerView.frame = CGRectMake((self.view.frame.size.width - 250)*0.5, 64 + 50, 250, (80 +5) * (9 / 3) - 5);
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(imgX, imgY, 80, 80)];
        img.userInteractionEnabled = YES;
        img.contentMode = UIViewContentModeScaleAspectFill;
        img.clipsToBounds = YES;
        img.tag = i;
        NSString *imgUrl = self.netImageArray[i];
        [img sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:nil];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [img addGestureRecognizer:tap];
        
        [self.containerView addSubview:img];
        [self.imageArray addObject:img];
    }
}

//图片点击事件
-(void)tapAction:(UITapGestureRecognizer *)tap
{
    
    

    PhotoBrowser *photoBrowser = [PhotoBrowser photoBrowser];
    photoBrowser.currentIndex = tap.view.tag;
    photoBrowser.originalPhoto = self.imageArray;
    [photoBrowser show];

    
    
}

-(NSMutableArray *)imageArray
{
    if (!_imageArray) {
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}

-(UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 250)*0.5, 64 + 50, 250, self.view.frame.size.height - 64 - 50)];
        _containerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _containerView;
}

#pragma makr    懒加载
-(NSMutableArray *)netImageArray{
    
    if (!_netImageArray) {
        
        // 加载plist中的字典数组
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Picture.plist" ofType:nil];
        NSArray *tempUrls = [NSArray arrayWithContentsOfFile:path];
        _netImageArray = [NSMutableArray arrayWithArray:tempUrls];
        
    }
    
    return _netImageArray;
    
}


@end
