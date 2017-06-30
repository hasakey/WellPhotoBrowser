//
//  PhotoBrowser.h
//  WellPhotoBrowser
//
//  Created by 同筑科技 on 2017/6/30.
//  Copyright © 2017年 well. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PhotoBrowserBlock)();

@interface PhotoBrowser : UIView

/**
 *  当前的index
 */
@property (nonatomic,assign) NSInteger currentIndex;

@property(nonatomic,strong)NSMutableArray *originalPhoto;

/**
 *  显示图片浏览器
 */
-(void)show;
/**
 *  返回图片浏览器
 */
+ (instancetype)photoBrowser;

@property(nonatomic,copy)PhotoBrowserBlock photoBrowserBlock;

@end
