//
//  ILSHandView.m
//  ImageTest
//
//  Created by 周和生 on 13-5-28.
//  Copyright (c) 2013年 周和生. All rights reserved.
//

#import "ILSHandView.h"
#import "ILSPivot.h"

@interface  ILSHandView() {
    CGPoint startLocation;
}
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation ILSHandView

- (id)initWithPivot: (ILSPivot*) pivot clippingRect:(CGRect)clippingRect {
    if (self = [super initWithFrame:CGRectZero]) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        
        _clippingRect = clippingRect;
        
        self.pivot = pivot;
        self.bounds = CGRectMake(0, 0, 20, 20);
        
        self.pivot.clippingRect = clippingRect;
        self.center = pivot.handViewCenter;

        self.imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        self.imageView.image = [UIImage imageNamed:@"drag_icon.png"];
        [self addSubview:self.imageView]; 
    }
    return self;
}

- (void)setClippingRect:(CGRect)clippingRect {
    _clippingRect = clippingRect;
    self.pivot.clippingRect = clippingRect;
    self.center = self.pivot.handViewCenter;
}

- (void)reLocation {
    self.center = self.pivot.handViewCenter;
}

#pragma Touch move
- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	// Calculate and store offset, and pop view into front if needed
	CGPoint pt = [[touches anyObject] locationInView:self];
	startLocation = pt;
	NSLog(@"------------------ILSHandView Starting: %f %f",self.center.x,self.center.y);
    
}

- (void)makeMoveWithDx: (CGFloat)dx andDy:(CGFloat)dy {
    [self.pivot handleMovement:CGSizeMake(dx, dy)];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	// Calculate offset
	CGPoint pt = [[touches anyObject] locationInView:self];
	float dx = pt.x - startLocation.x;
	float dy = pt.y - startLocation.y;
    [self makeMoveWithDx:dx andDy:dy];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint pt = [[touches anyObject] locationInView:self];
    NSLog(@"ILSHandView touchesEnded %@ -> %@", NSStringFromCGPoint(startLocation), NSStringFromCGPoint(pt));
}

@end



