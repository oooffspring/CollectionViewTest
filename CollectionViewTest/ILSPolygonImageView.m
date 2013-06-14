//
//  ILSPolygonImageView.m
//  ImageTest
//
//  Created by 周和生 on 13-5-27.
//  Copyright (c) 2013年 周和生. All rights reserved.
//
#import "ILSPolygonImageView.h"
#import "QuartzCore/QuartzCore.h"

@interface ILSPolygonImageView () <UIScrollViewDelegate> {
    CGPoint _topLeft, _bottomRight;
}
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, strong) NSMutableDictionary *startPoint, *endPoint;
@end


@implementation ILSPolygonImageView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor darkGrayColor];
    }
    return self;
}


- (void)setupContentViews {
    if (self.vertex.count<3) {
        return;
    }
    
    [self.imageView removeFromSuperview];
    [self.scrollView removeFromSuperview];
    
    CGRect rect = CGRectMake(_topLeft.x, _topLeft.y, _bottomRight.x-_topLeft.x, _bottomRight.y-_topLeft.y);
    self.scrollView = [[UIScrollView alloc]initWithFrame:rect];
    [self addSubview:self.scrollView];
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    self.imageView = [[UIImageView alloc]initWithImage:self.image];
    [self.scrollView addSubview:self.imageView];
    
    CGSize size = self.image.size;
    if (size.width>0.0f && size.height>0.0f) {
        CGFloat ratiox = rect.size.width/size.width;
        CGFloat ratioy = rect.size.height/size.height;
        self.scrollView.minimumZoomScale = MAX(ratiox, ratioy);
        self.scrollView.maximumZoomScale = MAX(self.scrollView.minimumZoomScale, 3);
        
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        //NSLog(@"zoomScale is _min %f _max %f", self.scrollView.minimumZoomScale, self.scrollView.maximumZoomScale);
    } else {
        self.imageView.frame = CGRectZero;
    }
    
}

#pragma - mark UIScrollView delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (scrollView==self.scrollView) {
        return self.imageView;
    }
    
    return nil;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (scrollView==self.scrollView) {
        CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
        CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
        self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,  scrollView.contentSize.height * 0.5 + offsetY);
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.shapeLayer==nil) {
        return nil;
    } else if (CGPathContainsPoint(self.shapeLayer.path, NULL, point, YES)) {
        return self.scrollView;
    } else {
        return nil;
    }
}


- (void)setupCurvePoints {
    if (self.vertex.count<3) {
        return;
    }
    
    self.startPoint = [NSMutableDictionary dictionaryWithCapacity:self.vertex.count];
    self.endPoint = [NSMutableDictionary dictionaryWithCapacity:self.vertex.count];
    if (self.bendPercent > 0.0f && self.bendPercent <= 0.5f) {
        for (NSUInteger index=0; index<self.vertex.count; index++) {
            NSUInteger indexNext = (index==self.vertex.count-1)?0:index+1;
            
            NSValue *value1 = [self.vertex objectAtIndex:index];
            NSValue *value2 = [self.vertex objectAtIndex:indexNext];
            CGPoint p1, p2, m1, m2;
            [value1 getValue:&p1];
            [value2 getValue:&p2];
            
            m1.x = p2.x * _bendPercent + p1.x * (1.0f - _bendPercent);
            m1.y = p2.y * _bendPercent + p1.y * (1.0f - _bendPercent);
            [self.endPoint setObject:[NSValue valueWithCGPoint:m1] forKey:[NSNumber numberWithInteger:index]];
            
            m2.x = p1.x * _bendPercent + p2.x * (1.0f - _bendPercent);
            m2.y = p1.y * _bendPercent + p2.y * (1.0f - _bendPercent);
            [self.startPoint setObject:[NSValue valueWithCGPoint:m2] forKey:[NSNumber numberWithInteger:indexNext]];
            
            //NSLog(@"percent %f, p1 %@ m1 %@ m2 %@ p2 %@", _bendPercent, NSStringFromCGPoint(p1), NSStringFromCGPoint(m1), NSStringFromCGPoint(m2), NSStringFromCGPoint(p2));
        }
        
    } else {
        NSLog(@"setupCurvePoints no curve");
        self.bendPercent = 0.0f;
    }
}


- (void)setupEdges {
    if (self.vertex.count<3) {
        return;
    }
    
    [self setupCurvePoints];
    
    self.shapeLayer = [CAShapeLayer layer];
    [self.shapeLayer setFillColor:[[UIColor whiteColor] CGColor]];
    
    CGMutablePathRef path = CGPathCreateMutable();
    NSInteger index = 0;
    for (NSValue *value in self.vertex) {
        CGPoint p;
        [value getValue:&p];
        //NSLog(@"makeEdges vertex is %@", NSStringFromCGPoint(p));
        
        if (index==0) {
            if (_bendPercent==0.0) {
                CGPathMoveToPoint(path, NULL, p.x, p.y);
            } else {
                NSValue *v1 = [self.startPoint objectForKey:[NSNumber numberWithInteger:index]];
                NSValue *v2 = [self.endPoint objectForKey:[NSNumber numberWithInteger:index]];
                CGPoint p1, p2;
                [v1 getValue:&p1];
                [v2 getValue:&p2];
                
                CGPathMoveToPoint(path, NULL, p1.x, p1.y);
                CGPathAddQuadCurveToPoint(path, NULL, p.x, p.y, p2.x, p2.y);
            }
            
            _topLeft = p;
            _bottomRight = p;
        } else {
            if (_bendPercent==0.0) {
                CGPathAddLineToPoint(path, NULL, p.x, p.y);
            } else {
                NSValue *v1 = [self.startPoint objectForKey:[NSNumber numberWithInteger:index]];
                NSValue *v2 = [self.endPoint objectForKey:[NSNumber numberWithInteger:index]];
                CGPoint p1, p2;
                [v1 getValue:&p1];
                [v2 getValue:&p2];
                
                CGPathAddLineToPoint(path, NULL, p1.x, p1.y);
                CGPathAddQuadCurveToPoint(path, NULL, p.x, p.y, p2.x, p2.y);
            }
            
            if (p.x<_topLeft.x) _topLeft.x = p.x;
            if (p.y<_topLeft.y) _topLeft.y = p.y;
            if (p.x>_bottomRight.x) _bottomRight.x = p.x;
            if (p.y>_bottomRight.y) _bottomRight.y = p.y;
        }
        
        index++;
    }
    CGPathCloseSubpath(path);
    [self.shapeLayer setPath:path];
    CFRelease(path);
    self.layer.mask = self.shapeLayer;
    //NSLog(@"_topLeft is %@ and _bottomRight is %@", NSStringFromCGPoint(_topLeft), NSStringFromCGPoint(_bottomRight));
    
    CGRect rect = CGRectMake(_topLeft.x, _topLeft.y, _bottomRight.x-_topLeft.x, _bottomRight.y-_topLeft.y);
    self.scrollView.frame = rect;
    
    CGSize size = self.image.size;
    if (size.width>0.0f && size.height>0.0f) {
        CGFloat ratiox = rect.size.width/size.width;
        CGFloat ratioy = rect.size.height/size.height;
        self.scrollView.minimumZoomScale = MAX(ratiox, ratioy);
        self.scrollView.maximumZoomScale = MAX(self.scrollView.minimumZoomScale, 3);
        
        if (self.scrollView.zoomScale < self.scrollView.minimumZoomScale) {
            self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        }
        
        //NSLog(@"zoomScale is _min %f _max %f", self.scrollView.minimumZoomScale, self.scrollView.maximumZoomScale);
    } else {
        self.imageView.frame = CGRectZero;
    }
    
}


@end
