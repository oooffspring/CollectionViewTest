//
//  ILSPolygonImageView.h
//  ImageTest
//
//  Created by 周和生 on 13-5-27.
//  Copyright (c) 2013年 周和生. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ILSPolygonImageView : UIView
@property (nonatomic, strong) NSArray *vertex;
@property (nonatomic, assign) CGFloat bendPercent;
@property (nonatomic, strong) UIImage *image;

- (void)setupContentViews;
- (void)setupEdges;
@end
