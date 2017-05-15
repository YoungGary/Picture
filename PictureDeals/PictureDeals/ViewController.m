//
//  ViewController.m
//  PictureDeals
//
//  Created by YOUNG on 2017/5/15.
//  Copyright © 2017年 Young. All rights reserved.
//

#import "ViewController.h"

#define Mask8(x)  (  (x) & 0xFF )

#define R(x)  ( Mask8(x) )
#define G(x)  ( Mask8(x >> 8 )  )
#define B(x)  ( Mask8(x >> 16)  )
#define A(x)  ( Mask8(x >> 24)  )

#define RGBAMake(r, g, b, a)  (  Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)reserveButton:(id)sender {
   self.bgImageView.image = [UIImage imageNamed:@"IMG_1091.jpg"];
    
}
- (IBAction)whiteImage:(id)sender {
    UIImage *orgin = self.bgImageView.image;
    self.bgImageView.image = [self whiteImage:orgin Whiteness:40];

}

- (IBAction)gratImage:(id)sender {
    UIImage *orgin = self.bgImageView.image;
    self.bgImageView.image = [self imageToGrayWithImage:orgin];
}

#pragma mark -- 灰色

- (UIImage *)imageToGrayWithImage:(UIImage *)image {
    // 1.拿到图片，获取宽高
    CGImageRef imageRef = image.CGImage;
    NSInteger width = CGImageGetWidth(imageRef);
    NSInteger height = CGImageGetHeight(imageRef);
    
    // 2:创建
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    
    CGContextRef contextRef = CGBitmapContextCreate(nil,
                                                    width,
                                                    height,
                                                    8, // 固定写法  8位
                                                    width * 4, // 每一行的字节  宽度 乘以32位 = 4字节
                                                    colorSpaceRef,
                                                    kCGImageAlphaNone); // 无透明度
    if (!contextRef) {
        return image;
    }
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    
    CGImageRef grayImageRef = CGBitmapContextCreateImage(contextRef);
    UIImage * graryImage = [UIImage imageWithCGImage:grayImageRef];
    //释放内存
    CGColorSpaceRelease(colorSpaceRef);
    CGContextRelease(contextRef);
    CGImageRelease(grayImageRef);
    return graryImage;
}
#pragma mark -- 美白

- (UIImage *)whiteImage:(UIImage *)image
              Whiteness:(int)whiteness {
    
    if (!whiteness || whiteness < 10 ||  whiteness > 150) {
        return image;
    }
    
    // 1.拿到图片，获取宽高
    CGImageRef imageRef =image.CGImage;
    NSInteger width = CGImageGetWidth(imageRef);
    NSInteger height = CGImageGetHeight(imageRef);
    
    // 2:创建颜色空间（灰色空间， 彩色空间）->  开辟一块内存空间
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    
    // 3:创建图片上下文
    // 为什么是UInt32类型，即是无符号32为int型 取值范围就是0-255之间
    // inputPixels是像素点集合的首地址
    UInt32 * inputPixels = (UInt32*)calloc(width * height, sizeof(UInt32));
    
    CGContextRef contextRef = CGBitmapContextCreate(inputPixels,
                                                    width,
                                                    height,
                                                    8, // 固定写法  8位
                                                    width * 4, // 每一行的字节  宽度 乘以32位 = 4字节
                                                    colorSpaceRef,
                                                    kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big); // 自己查咯
    
    // 4:根据图片上线纹绘制图片
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    
    // 5：循环遍历每个像素点进行修改
    for (int i = 0; i < height; i ++) {
        for (int j = 0; j <  width; j ++) {
            UInt32 * currentPixels = inputPixels + (i * width) + j; // 改变指针的指向  每一个像素点都能遍历到了
            UInt32 color = *currentPixels;
            
            UInt32 colorA,colorR,colorG,colorB;
            
            colorR = R(color);   // 此处宏定义  计算RGBA的值  是通过位运算算的  自己百度咯
            colorR = colorR + whiteness;
            colorR = colorR > 255 ? 255 : colorR;
            
            colorG = G(color);
            colorG = colorG + whiteness;
            colorG = colorG > 255 ? 255 : colorG;
            
            colorB = B(color);
            colorB = colorB + whiteness;
            colorB = colorB > 255 ? 255 : colorB;
            
            colorA = A(color);
            *currentPixels = RGBAMake(colorR, colorG, colorB, colorA);
        }
    }
    
    
    // 6：创建Image对象
    CGImageRef newImageRef = CGBitmapContextCreateImage(contextRef);
    UIImage * newImage = [UIImage imageWithCGImage:newImageRef];
    
    // 7：释放内存
    CGColorSpaceRelease(colorSpaceRef);
    CGContextRelease(contextRef);
    CGImageRelease(newImageRef);
    free(inputPixels);
    
    return newImage;
    
}




@end
