//
//  UIImage+Utility.h
//
//  Created by Shangen Zhang on 2013/05/17.
//  Copyright (c) 2013年 Shangen Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger,UIImageRealType) {
    UIImageRealTypeNone,        // is not image data
    UIImageRealTypeJPEG,        // @"jpeg"
    UIImageRealTypePNG,         // @"png"
    UIImageRealTypeGIF,         // @"gif"
    UIImageRealTypeTIFF,        // @"tiff"
    UIImageRealTypeImage_WEBP,  // @"iamge/webp"
};


@interface NSData (ImageExtension)
// 图片真实类型
@property (readonly) UIImageRealType imageRealType;

+ (NSData *)dataWithPNGImage:(UIImage *)image;
+ (NSData *)dataWithJPEGImage:(UIImage *)image compressionQuality:(CGFloat)quality;
@end


@interface UIImage (CreateImage)
/**
 *  获取图片
 */
+ (UIImage *)fastImageWithData:(NSData*)data;
+ (UIImage *)fastImageWithContentsOfFile:(NSString*)path;
+ (UIImage *)fetchImageWithNameOrPath:(NSString *)imageNameOrPath;


/**
 * bundle 中加载图片
 */
+ (UIImage *)imageNamed:(NSString *)name withBundle:(NSString *)bundle;

/**
 * 截取view的图片
 */
+ (UIImage *)fetchImageFromView:(UIView *)view;

/**
 *  根据图片名获取一张原始图片（不被渲染的）
 */
+ (UIImage *)originImageWithName:(NSString *)imageName;

/**
 * 复制图片
 */
- (UIImage *)deepCopy;
@end


@interface UIImage (BundleImage)

@end



@interface UIImage (ColorImage)
/**
 * 生成纯颜色图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)innerRoundImageWithColor:(UIColor *)color size:(CGSize)size;

@end



@interface UIImage (ModifySize)

- (UIImage*)aspectToSize:(CGSize)size;
- (UIImage*)aspectFitToSize:(CGSize)size;

- (UIImage*)aspectFillToSize:(CGSize)size;
- (UIImage*)aspectFillToSize:(CGSize)size offset:(CGFloat)offset;

// 截取图片部分的内容
- (UIImage*)clipImageAtRect:(CGRect)rect;

/**
 *  压缩、放大图片
 */
- (UIImage *)compressImageWithTargetWidth:(CGFloat)targetWidth;
- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize;
- (NSData *)compressImageToMaxFileSize:(NSInteger)maxFileSize;

@end


@interface UIImage (Operations)
/**
 * 合成图片
 */
- (UIImage *)maskImageWithOtherImage:(UIImage*)maskImage;

/**
 * 重新设置图片的方向,防止上传到服务器,图片方向错误
 */
- (UIImage *)fixOrientation;

/**
 *  圆形拉伸
 */
+ (UIImage *)strechImageWithImageName:(NSString *)imageName;
+ (UIImage *)strechImageWithImageName:(NSString *)imageName
                              leftCap:(CGFloat)leftProgress
                               topCap:(CGFloat)topProgress;
/**
 *  圆形切图
 */
- (UIImage *)roundImage;
- (UIImage *)roundImageWithBorderW:(CGFloat)borderW borderColor:(UIColor *)borderColor;

/**
 *  图片加边框
 */
- (UIImage *)imageAddBorderWithWidth:(CGFloat)borderWidth color:(UIColor *)borderColor;
@end



@interface UIImage (BlurImage)
/**
 * 毛玻璃效果图片
 *
 * blurLevel 模糊程度 0 ≤ t ≤ 1
 */
- (UIImage *)gaussBlur:(CGFloat)blurLevel;

/**
 *  将彩色图片转化为灰色图片
 */
- (UIImage *)convertImageToGreyScale;

/**
 *  图片加蒙版
 */
- (UIImage *)imageWithOverlayColor:(UIColor *)overlayColor;

/**
 *  图片加水印
 */
- (UIImage *)waterImageWithLogo:(UIImage *)logoImage logoFrame:(CGRect)frame;
@end
