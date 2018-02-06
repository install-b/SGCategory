//
//  UIColor+SGHexColor.h
//  SGCategory
//
//  Created by Shangen Zhang on 16/12/13.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (SGHexColor)
    /**
     *  16进制自动转换RGB颜色
     *
     *  @param stringToConvert   传入16进制色值 如:@"ffffff"
     *
     *  @return 返回iOS中支持的RGB值
     *
     *  注意：iOS中默认不支持16进制色值，但是在公司中或者UI美工一般都使用标准的16进制表示颜色，
     *  我们可以通过这个方法将美工给的16进制颜色进行转换就OK了
     *
     */
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;

// +透明度
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert
                          alpha:(CGFloat)alpha;
    
@end
