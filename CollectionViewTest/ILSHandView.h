//
//  ILSHandView.h
//  ImageTest
//
//  Created by 周和生 on 13-5-28.
//  Copyright (c) 2013年 周和生. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ILSPivot;

@interface ILSHandView : UIView

@property (nonatomic) CGRect clippingRect;
@property (nonatomic, strong) ILSPivot *pivot;

- (id)initWithPivot: (ILSPivot*) pivot clippingRect: (CGRect)clippingRect;
- (void)reLocation;
@end
