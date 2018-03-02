//
//  UIImage+Utility.m
//
//  Created by Shangen Zhang on 2013/05/17.
//  Copyright (c) 2013年 Shangen Zhang. All rights reserved.
//

#import "UIImage+SGExtension.h"
#import <Accelerate/Accelerate.h>

@implementation NSData (ImageExtension)
- (UIImageRealType)imageRealType{
    uint8_t c;
    [self getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return UIImageRealTypeJPEG;
        case 0x89:
            return UIImageRealTypePNG;
        case 0x47:
            return UIImageRealTypeGIF;
        case 0x49:
        case 0x4D:
            return UIImageRealTypeTIFF;
        case 0x52:
            // R as RIFF for WEBP
            if ([self length] < 12) {
                return UIImageRealTypeNone;
            }
            
            NSString *testString = [[NSString alloc] initWithData:[self subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return UIImageRealTypeImage_WEBP;
            }
            return UIImageRealTypeNone;
    }
    return UIImageRealTypeNone;
}
+ (NSData *)dataWithPNGImage:(UIImage *)image {
    return  UIImagePNGRepresentation(image);
}
+ (NSData *)dataWithJPEGImage:(UIImage *)image compressionQuality:(CGFloat)quality {
    return UIImageJPEGRepresentation(image, quality);
}
@end


@implementation UIImage (CreateImage)
+ (UIImage*)fastImageWithData:(NSData *)data {
    return [[UIImage imageWithData:data] decodeImage];
}

+ (UIImage*)fastImageWithContentsOfFile:(NSString*)path {
    return [[UIImage imageWithContentsOfFile:path] decodeImage];
}

+ (UIImage *)fetchImageWithNameOrPath:(NSString *)imageNameOrPath {
    return [UIImage imageNamed:imageNameOrPath] ? :
    [UIImage imageWithContentsOfFile:imageNameOrPath] ;
}

+ (UIImage *)imageNamed:(NSString *)name withBundle:(NSString *)bundle {
    if ([bundle hasSuffix:@".bundle"]) {
        return [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@",bundle,name]];
    }
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@.bundle/%@",bundle,name]];
}


+(instancetype)fetchImageFromView:(UIView *)view {
    //应该给一个延迟的效果
    //获得图片上下文
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
    //将控制器的view的layer渲染到图层
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    //去除图片
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    // 结束上下文
    UIGraphicsEndImageContext();
    //将新图片压缩成二进制文件
    return newImage;
    
}


+ (instancetype)originImageWithName:(NSString *)imageName {
    return [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}


- (UIImage*)deepCopy {
    return [self decodeImage];
}

- (instancetype)decodeImage {
    UIImage *image = self;
    UIGraphicsBeginImageContext(image.size);
    {
        [image drawAtPoint:CGPointMake(0, 0)];
        image = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return image;
}
@end


@implementation UIImage (ColorImage)
// 根据一个颜色生成一张1*1的图片
+ (UIImage *)imageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:CGSizeMake(1.0f, 1.0f)];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

+ (UIImage *)innerRoundImageWithColor:(UIColor *)color size:(CGSize)size {
    // 描述矩形
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    
    // 获取位图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 使用color演示填充上下文
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    
    CGFloat minWidth = MIN(size.width,size.height);
    
    // 开启位图上下文
    UIGraphicsBeginImageContext(rect.size);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake((size.width - minWidth) * 0.5, (size.height - minWidth) * 0.5, minWidth, minWidth) cornerRadius:minWidth * 0.5];
    [color setFill];
    [path fill];
    // 渲染上下文
    CGContextFillRect(context, rect);
    
    // 从上下文中获取图片
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    // 结束上下文
    UIGraphicsEndImageContext();
    
    return theImage;
}
@end

@implementation UIImage (ModifySize)
- (UIImage*)aspectFitToSize:(CGSize)size {
    CGFloat ratio = MIN(size.width/self.size.width, size.height/self.size.height);
    return [self aspectToSize:CGSizeMake(self.size.width*ratio, self.size.height*ratio)];
}
- (UIImage*)aspectToSize:(CGSize)size
{
    int W = size.width;
    int H = size.height;
    
    CGImageRef   imageRef   = self.CGImage;
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    CGContextRef bitmap = CGBitmapContextCreate(NULL, W, H, 8, 4*W, colorSpaceInfo, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    
    CGColorSpaceRelease(colorSpaceInfo);
    
    if(self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationRight){
        W = size.height;
        H = size.width;
    }
    
    if(self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationLeftMirrored){
        CGContextRotateCTM (bitmap, M_PI/2);
        CGContextTranslateCTM (bitmap, 0, -H);
    }
    else if (self.imageOrientation == UIImageOrientationRight || self.imageOrientation == UIImageOrientationRightMirrored){
        CGContextRotateCTM (bitmap, -M_PI/2);
        CGContextTranslateCTM (bitmap, -W, 0);
    }
    else if (self.imageOrientation == UIImageOrientationUp || self.imageOrientation == UIImageOrientationUpMirrored){
        // Nothing
    }
    else if (self.imageOrientation == UIImageOrientationDown || self.imageOrientation == UIImageOrientationDownMirrored){
        CGContextTranslateCTM (bitmap, W, H);
        CGContextRotateCTM (bitmap, -M_PI);
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, W, H), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    //    CGContextRelease(bitmap);
    CGImageRelease(ref);
    return newImage;
}
- (UIImage*)aspectFillToSize:(CGSize)size {
    return [self aspectFillToSize:size offset:0];
}

- (UIImage*)aspectFillToSize:(CGSize)size offset:(CGFloat)offset {
    int W  = size.width;
    int H  = size.height;
    int W0 = self.size.width;
    int H0 = self.size.height;
    
    CGImageRef imageRef = self.CGImage;
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    CGContextRef bitmap = CGBitmapContextCreate(NULL, W, H, 8, 4*W, colorSpaceInfo, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    
    CGColorSpaceRelease(colorSpaceInfo);
    
    if(self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationRight){
        W  = size.height;
        H  = size.width;
        W0 = self.size.height;
        H0 = self.size.width;
    }
    
    double ratio = MAX(W/(double)W0, H/(double)H0);
    W0 = ratio * W0;
    H0 = ratio * H0;
    
    int dW = abs((W0-W)/2);
    int dH = abs((H0-H)/2);
    
    if(dW==0){ dH += offset; }
    if(dH==0){ dW += offset; }
    
    if(self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationLeftMirrored){
        CGContextRotateCTM (bitmap, M_PI/2);
        CGContextTranslateCTM (bitmap, 0, -H);
    }
    else if (self.imageOrientation == UIImageOrientationRight || self.imageOrientation == UIImageOrientationRightMirrored){
        CGContextRotateCTM (bitmap, -M_PI/2);
        CGContextTranslateCTM (bitmap, -W, 0);
    }
    else if (self.imageOrientation == UIImageOrientationUp || self.imageOrientation == UIImageOrientationUpMirrored){
        // Nothing
    }
    else if (self.imageOrientation == UIImageOrientationDown || self.imageOrientation == UIImageOrientationDownMirrored){
        CGContextTranslateCTM (bitmap, W, H);
        CGContextRotateCTM (bitmap, -M_PI);
    }
    
    CGContextDrawImage(bitmap, CGRectMake(-dW, -dH, W0, H0), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref scale:1.0 orientation:UIImageOrientationRight];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage;
}


//图片压缩到指定大小
- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (instancetype)compressImageWithTargetWidth:(CGFloat)targetWidth {
    CGSize imageSize = self.size;
    
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetHeight = (targetWidth / width) * height;
    
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    [self drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

- (NSData *)compressImageToMaxFileSize:(NSInteger)maxFileSize{
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(self, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression) {
        compression -= 0.2;
        imageData = UIImageJPEGRepresentation(self, compression);
    }
    return imageData;
}

- (UIImage*)clipImageAtRect:(CGRect)rect {
    CGPoint origin = CGPointMake(-rect.origin.x, -rect.origin.y);
    UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.height));
    [self drawAtPoint:origin];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
@end

@implementation UIImage (Operations)
- (UIImage*)maskImageWithOtherImage:(UIImage*)maskImage
{
    CGImageRef maskCGImage = maskImage.CGImage;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskCGImage),
                                        CGImageGetHeight(maskCGImage),
                                        CGImageGetBitsPerComponent(maskCGImage),
                                        CGImageGetBitsPerPixel(maskCGImage),
                                        CGImageGetBytesPerRow(maskCGImage),
                                        CGImageGetDataProvider(maskCGImage), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask(self.CGImage, mask);
    
    UIImage *result = [UIImage imageWithCGImage:masked];
    
    CGImageRelease(maskCGImage);
    CGImageRelease(mask);
    CGImageRelease(masked);
    
    return result;
}
- (UIImage *)fixOrientation {
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
    return [self strechImageWithImageName:imageName leftCap:0.5 topCap:0.5];
}

+ (UIImage *)strechImageWithImageName:(NSString *)imageName leftCap:(CGFloat)leftProgress topCap:(CGFloat)topProgress {
    
    UIImage *image = [UIImage imageNamed:imageName];
    
    return   [image stretchableImageWithLeftCapWidth:image.size.width * leftProgress topCapHeight:image.size.height * topProgress];
}

- (UIImage *)roundImage {
    CGSize size = self.size;
    
    UIGraphicsBeginImageContext(size);
    //4.绘制一个大圆0
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, size.width, size.height)];
    
    [path fill];
    //5.设置裁剪区域
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, size.width, size.height)];
    //6.把路径设置成裁剪区域
    [clipPath addClip];
    
    //7.把图片绘制到上下文当中
    [self drawAtPoint:CGPointZero];
    
    //8.从上下文当中生成一张图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //9.关闭上下文
    UIGraphicsEndImageContext();
    
    return newImage;
    
    
}

- (UIImage *)roundImageWithBorderW:(CGFloat)borderW borderColor:(UIColor *)borderColor {
    
    //3.开启一个位图上下文
    CGSize size = CGSizeMake(self.size.width + 2 * borderW, self.size.height + 2 * borderW);
    UIGraphicsBeginImageContext(self.size);
    //4.绘制一个大圆0
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, size.width, size.height)];
    [borderColor set];
    [path fill];
    //5.设置裁剪区域
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(borderW, borderW, self.size.width, self.size.height)];
    //6.把路径设置成裁剪区域
    [clipPath addClip];
    
    //7.把图片绘制到上下文当中
    [self drawAtPoint:CGPointMake(borderW, borderW)];
    //8.从上下文当中生成一张图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //9.关闭上下文
    UIGraphicsEndImageContext();
    
    
    CGRect drawRect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    drawRect.size.width *= [UIScreen mainScreen].scale - 1;
    drawRect.size.height *= [UIScreen mainScreen].scale - 1;
    // 9.生成CG图片
    CGImageRef CGImage = CGImageCreateWithImageInRect(newImage.CGImage, drawRect);
    // 10.转化为OC图片
    newImage = [UIImage imageWithCGImage:CGImage];
    
    
    return newImage;
}
- (UIImage *)imageAddBorderWithWidth:(CGFloat)borderWidth color:(UIColor *)borderColor {
    
    CGFloat borberW   = borderWidth;
    CGFloat imageW    = self.size.width+borberW*2;
    CGFloat imageH    = self.size.height+borberW*2;
    CGSize  imageSize = CGSizeMake(imageW, imageH);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    
    CGContextRef ref=UIGraphicsGetCurrentContext();
    //画一个大圆
    [borderColor set];
    CGFloat bigRadius=imageW*0.5;
    CGFloat bigX=imageW*0.5;
    CGFloat bigY=imageH*0.5;
    CGContextAddArc(ref, bigX, bigY, bigRadius, 0, M_PI*2, 0);
    //渲染到图层
    CGContextFillPath(ref);
    
    //画一个小圆
    CGFloat smallRadius=bigRadius-borberW;
    CGContextAddArc(ref, bigX, bigY, smallRadius, 0, M_PI*2, 0);
    //裁剪
    CGContextClip(ref);
    //画图
    [self drawInRect:CGRectMake(borberW, borberW, self.size.width, self.size.height)];
    //去除图片
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    return newImage;
}
@end





@implementation UIImage (BlurImage)
- (UIImage*)gaussBlur:(CGFloat)blurLevel
{
    blurLevel = MIN(1.0, MAX(0.0, blurLevel));
    
    int boxSize = (int)(blurLevel * 0.1 * MIN(self.size.width, self.size.height));
    boxSize = boxSize - (boxSize % 2) + 1;
    
    NSData *imageData = UIImageJPEGRepresentation(self, 1);
    UIImage *tmpImage = [UIImage imageWithData:imageData];
    
    CGImageRef img = tmpImage.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    //create vImage_Buffer with data from CGImageRef
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    NSInteger windowR = boxSize/2;
    CGFloat sig2 = windowR / 3.0;
    if(windowR>0){ sig2 = -1/(2*sig2*sig2); }
    
    int16_t *kernel = (int16_t*)malloc(boxSize*sizeof(int16_t));
    int32_t  sum = 0;
    for(NSInteger i=0; i<boxSize; ++i){
        kernel[i] = 255*exp(sig2*(i-windowR)*(i-windowR));
        sum += kernel[i];
    }
    
    // convolution
    error = vImageConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, kernel, boxSize, 1, sum, NULL, kvImageEdgeExtend);
    error = vImageConvolve_ARGB8888(&outBuffer, &inBuffer, NULL, 0, 0, kernel, 1, boxSize, sum, NULL, kvImageEdgeExtend);
    outBuffer = inBuffer;
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             kCGBitmapAlphaInfoMask & kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    CFRelease(inBitmapData);
    CGImageRelease(imageRef);
    
    return returnImage;
}

- (UIImage*)convertImageToGreyScale {
    
    CGRect imageRect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, self.size.width, self.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    CGContextDrawImage(context, imageRect, [self CGImage]);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    return newImage;
}

- (instancetype)imageWithOverlayColor:(UIColor *)overlayColor
{
    UIImage *image = self;
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextSetFillColorWithColor(context, [overlayColor CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage
                                                scale:1.0 orientation: UIImageOrientationDownMirrored];
    
    return flippedImage;
}

- (UIImage *)waterImageWithLogo:(UIImage *)logoImage logoFrame:(CGRect)frame{
    // 开启位图上下文
    UIGraphicsBeginImageContextWithOptions(self.size, YES, 0.0);
    //2.绘制底层图片
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    
    // 绘制log
    [logoImage drawInRect:frame];
    
    //4.从上下文去除获得的新图片对象
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    //5.结束上下次文
    UIGraphicsEndImageContext();
    //返回新创建的图片对象
    return newImage;
}
@end
