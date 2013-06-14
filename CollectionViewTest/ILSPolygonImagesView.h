//
//  ILSPloygonImageView.h
//  ImageTest
//
//  Created by 周和生 on 13-5-22.
//  Copyright (c) 2013年 周和生. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILSDefines.h"
#import "ILSPivot.h"


@interface ILSPolygonImagesView : UIView<ILSPivotDelegate>
@property (nonatomic, assign) CGFloat bendPercent;
@property (nonatomic, assign) CGFloat outEdgeWidth;
@property (nonatomic, assign) CGFloat polygonOffset;

- (void)setupVertexWithString: (NSString *) pointStr;
- (void)setupSlotsWithString: (NSString *) slotStr;
- (void)setupPivotsWithString: (NSString *) pivotStr;

- (void)setupSubViewsForPolygons;
- (void)setupHandViews;
@end
