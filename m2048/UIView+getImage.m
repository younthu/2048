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
    // Captures SpriteKit content!
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}
@end
