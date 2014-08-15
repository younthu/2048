//
//  UIView+getImage.m
//  m2048
//
//  Created by Yang, Andrew on 8/15/14.
//  Copyright (c) 2014 Danqing. All rights reserved.
//

#import "UIView+getImage.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (getImage)
-(UIImage *)getImage{
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
