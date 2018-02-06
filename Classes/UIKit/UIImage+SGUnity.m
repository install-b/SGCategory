//
//  UIImage+SGUnity.m
//  SGCategory
//
//  Created by Shangen Zhang on 16/12/13.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import "UIImage+SGUnity.h"

@implementation UIImage (SGUnity)
- (UIImage *)imageWithClipSize:(CGSize)showSize {
    // 缩放比例
    CGFloat scale;
    // 裁剪区域  //3.设置裁剪区域
    CGRect clickRect = CGRectMake(0, 0 , showSize.width, showSize.height);
    
    // 图片缩放后的尺寸
    CGSize size;
    
    // 算出宽高比例 用于判断横竖类型
    CGFloat scaleWH = 1.0 * self.size.width / self.size.height;
    
    if (scaleWH > 1) { // 横屏的
        
        scale = showSize.height / self.size.height;
        // 1.设置缩放size
        size = CGSizeMake(self.size .width * scale, self.size.height * scale);
        
    }else { // 竖屏状态
        
        scale = showSize.width/ self.size.width;
        // 1.设置缩放size
        size = CGSizeMake(self.size .width * scale, self.size.height * scale);
        
    }
    
    
    // 1. 开启图形上下文
    UIGraphicsBeginImageContext(showSize);
    
    // 2.设置绘制范围
    CGRect drawRect;
    if (scaleWH > 1) { //  横屏
        
        drawRect = CGRectMake(-(size.width - showSize.width)* 0.5, 0, size.width, size.height);
    }else {
        
        drawRect = CGRectMake(0, -(size.height - showSize.height)* 0.5, size.width, size.height);
        
    }
    
    // 3.设置裁剪区域
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:clickRect];
    
    //4.把路径设置成裁剪区域
    [path addClip];
    
    //5.把图片绘制到上下文当中
    [self drawInRect:drawRect];
    
    
    //6.从上下文当中生成一张图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //7.关闭位图上下文
    UIGraphicsEndImageContext();
    
    // 8.图片裁剪(将尺寸修改为选中后的尺寸)
    // 转化为像素坐标
    
    drawRect.size.width *= [UIScreen mainScreen].scale;
    drawRect.size.height *= [UIScreen mainScreen].scale;
    // 9.生成CG图片
    CGImageRef CGImage = CGImageCreateWithImageInRect(newImage.CGImage, drawRect);
    // 10.转化为OC图片
    newImage = [UIImage imageWithCGImage:CGImage];
    
    return newImage;
}


/** 根据图片名称 返回一张带边框的图片圆形图片 borderW：边框的宽度 borderColor：边框颜色  */
+ (UIImage *)imageWithBorderW:(CGFloat)borderW borderColor:(UIColor *)borderColor imageName:(NSString *)imageName {
    return [[UIImage imageNamed:imageName] roundImageWithBorderW:borderW borderColor:borderColor];
}
- (UIImage *)roundImageWithBorderW:(CGFloat)borderW borderColor:(UIColor *)borderColor {
    //1.开启一个位图上下文
    CGSize size = CGSizeMake(self.size.width + 2 * borderW, self.size.height + 2 * borderW);
    UIGraphicsBeginImageContext(self.size);
    //2.绘制一个大圆0
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, size.width, size.height)];
    [borderColor set];
    [path fill];
    //3.设置裁剪区域
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(borderW, borderW, self.size.width, self.size.height)];
    //4.把路径设置成裁剪区域
    [clipPath addClip];
    
    //5.把图片绘制到上下文当中
    [self drawAtPoint:CGPointMake(borderW, borderW)];
    //6.从上下文当中生成一张图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //7.关闭上下文
    UIGraphicsEndImageContext();
    CGRect drawRect = CGRectMake(0, 0, self.size.width, self.size.height);
    drawRect.size.width *= [UIScreen mainScreen].scale - 1;
    drawRect.size.height *= [UIScreen mainScreen].scale - 1;
    // 8.生成CG图片
    CGImageRef CGImage = CGImageCreateWithImageInRect(newImage.CGImage, drawRect);
    // 9.转化为OC图片
    newImage = [UIImage imageWithCGImage:CGImage];
    
    return newImage;
}


/** 根据图片名称 返回一张带边框的圆形图片  */
+ (UIImage *)imageWithimageName:(NSString *)imageName {
    return [[UIImage imageNamed:imageName] roundImage];
}

/** 切割出一张带边框的圆形图片  */
- (UIImage *)roundImage {
    return [self roundImageWithBorderW:0 borderColor:nil];
}


// 根据一个颜色生成一张1*1的图片
+ (UIImage *)imageWithColor:(UIColor *)color{
    // 描述矩形
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    // 开启位图上下文
    UIGraphicsBeginImageContext(rect.size);
    // 获取位图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 使用color演示填充上下文
    CGContextSetFillColorWithColor(context, [color CGColor]);
    // 渲染上下文
    CGContextFillRect(context, rect);
    // 从上下文中获取图片
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    // 结束上下文
    UIGraphicsEndImageContext();
    
    return theImage;
}


+ (instancetype)originImageWithName:(NSString *)imageName {
    return [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

+ (instancetype)originImageWithContentFile:(NSString *)filePath {
    return [[UIImage imageWithContentsOfFile:filePath] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}


- (UIImage *)sg_fixOrentation {
    if(self.imageOrientation == UIImageOrientationUp) return self;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch(self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width,0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform,0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    switch(self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width,0);
            transform = CGAffineTransformScale(transform, -1,1);
            break;
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height,0);
            transform = CGAffineTransformScale(transform, -1,1);
            break;
        default:
            break;
    }
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage),0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch(self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}



+ (UIImage *)strechImageWithImageName:(NSString *)imageName {
    
    UIImage *image = [UIImage imageNamed:imageName];
    
    return   [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}

+ (UIImage *)strechImageWithImageName:(NSString *)imageName leftCap:(CGFloat)leftProgress
                               topCap:(CGFloat)topProgress {
    
    
    UIImage *image = [UIImage imageNamed:imageName];
    
    return   [image stretchableImageWithLeftCapWidth:image.size.width * leftProgress topCapHeight:image.size.height * topProgress];
}

// 根据传进来的view返回当前view的截屏图片
+ (UIImage *)imageForView:(UIView *)view {
    //把UIView的上的内容生成一张图片
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    // 获取当前上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //把View的内容渲染到上下文当中
    [view.layer renderInContext:ctx];
    
    //从上下文当中生成一张图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //关闭上下文
    UIGraphicsEndImageContext();
    
    // 返回一张图片
    return newImage;
}
@end
