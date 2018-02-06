//
//  UIImage+SGUnity.h
//  SGCategory
//
//  Created by Shangen Zhang on 16/12/13.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SGUnity)
/** 根据颜色生成一张尺寸为1*1的相同颜色图片 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/** 图片保持原来的压缩比返回一张特定尺寸裁剪的图片  */
- (UIImage *)imageWithClipSize:(CGSize)showSize;

/**
 修正图片正反 方向
 
 @return 新的image
 */
- (UIImage *)sg_fixOrentation;

#pragma mark -
/**
 *  根据图片名返回一张原始图片(不进行渲染的图片)
 */
+ (instancetype)originImageWithName:(NSString *)imageName;

/**
 *  根据图片路径名返回一张原始图片(不进行渲染的图片)
 */
+ (instancetype)originImageWithContentFile:(NSString *)filePath;


#pragma mark -
/** 根据图片名称 返回一张带边框的图片圆形图片 borderW：边框的宽度 borderColor：边框颜色  */
+ (UIImage *)imageWithBorderW:(CGFloat)borderW borderColor:(UIColor *)borderColor imageName:(NSString *)imageName;

/** 切割出一张带边框的图片圆形图片 borderW：边框的宽度 borderColor：边框颜色  */
- (UIImage *)roundImageWithBorderW:(CGFloat)borderW borderColor:(UIColor *)borderColor;

/** 根据图片名称 返回一张带边框的圆形图片  */
+ (UIImage *)imageWithimageName:(NSString *)imageName;

/** 切割出一张带边框的圆形图片  */
- (UIImage *)roundImage;

#pragma mark -

/** 返回一张拉伸的图片 */
+ (UIImage *)strechImageWithImageName:(NSString *)imageName;

/** 返回一张设置拉伸位置的图片 leftCap: 距离左侧拉伸位置（0-1之间,0.5标示中间） topCap:距离左侧拉伸位置 */
+ (UIImage *)strechImageWithImageName:(NSString *)imageName
                              leftCap:(CGFloat)leftProgress
                               topCap:(CGFloat)topProgress;

/** 根据传进来的view返回当前view的截屏图片 */
+ (UIImage *)imageForView:(UIView *)view;
@end
