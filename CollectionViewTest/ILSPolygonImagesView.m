//
//  ILSPloygonImageView.m
//  ImageTest
//
//  Created by 周和生 on 13-5-22.
//  Copyright (c) 2013年 周和生. All rights reserved.
//

#import "ILSPolygonImageView.h"
#import "ILSPolygonImagesView.h"
#import "ILSCLipper.h"
#import "ILSHandView.h"

@interface ILSPolygonImagesView()
@property (nonatomic, strong) NSMutableArray *vertex;
@property (nonatomic, strong) NSMutableArray *slots;
@property (nonatomic, strong) NSMutableArray *pivots;

@property (nonatomic, strong) NSMutableDictionary *slotImages;
@property (nonatomic, strong) NSMutableDictionary *slotViews;
@property (nonatomic, strong) NSMutableDictionary *handViews;
@end

@implementation ILSPolygonImagesView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _polygonOffset = -10.0f;
        _bendPercent = 0.0f;
        _outEdgeWidth = 0.0f;
    }
    return self;
}

- (void)setupHandViews {
    for (ILSHandView *view in self.handViews.allValues) {
        [view removeFromSuperview];
    }
    self.handViews = [NSMutableDictionary dictionaryWithCapacity:self.pivots.count];
    
    NSUInteger index = 0;
    CGRect innerRect = CGRectInset(self.bounds, _outEdgeWidth, _outEdgeWidth);
    for (ILSPivot *eachPivot in self.pivots) {
        ILSHandView *handView = [[ILSHandView alloc]initWithPivot:eachPivot clippingRect:innerRect];
        [self.handViews setObject:handView forKey:[NSNumber numberWithInteger:index]];
        [self addSubview:handView];
        NSLog(@"handView is %@", handView);
        index++;
    }
}

- (void)setupSubViewsForPolygons {
    for (ILSPolygonImageView *view in self.slotViews.allValues) {
        [view removeFromSuperview];
    }
    
    self.slotImages = [NSMutableDictionary dictionaryWithCapacity:self.slots.count];
    self.slotViews = [NSMutableDictionary dictionaryWithCapacity:self.slots.count];
    NSUInteger index = 0;
    
    for (NSMutableArray *slotPois in self.slots) {
        ILSPolygonImageView *pView = [[ILSPolygonImageView alloc]initWithFrame:self.bounds];
        
        pView.bendPercent = _bendPercent;
        [self setupEdgesFor:pView withSlot:slotPois];

        [self addSubview:pView];
        
        UIImage *image;
        int r = arc4random()%3;
        if (r==0) {
            image = [UIImage imageNamed:@"picture.png"];
        } else if (r==1) {
            image = [UIImage imageNamed:@"flower.jpg"];
        } else {
            image = [UIImage imageNamed:@"beauty.jpg"];
        }
        pView.image = image;
        
        [pView setupContentViews];
        
        [self.slotImages setObject:image forKey:[NSNumber numberWithInteger:index]];
        [self.slotViews setObject:pView forKey:[NSNumber numberWithInteger:index]];
       
        index++;
        
    }
}

- (void)setupEdgesFor: (ILSPolygonImageView *)pView  withSlot: (NSMutableArray *) slotPois {
    NSMutableArray *vs = [NSMutableArray arrayWithCapacity:slotPois.count];
    for (NSNumber *index in slotPois) {
        [vs addObject:[self.vertex objectAtIndex:index.integerValue]];
    }
    
    NSArray *boundedVertex;
    if (_outEdgeWidth > 0.0f && _outEdgeWidth < self.bounds.size.width/2.0f && _outEdgeWidth < self.bounds.size.height/2.0f) {
        CGRect innerRect = CGRectInset(self.bounds, _outEdgeWidth, _outEdgeWidth);
        NSArray *clipper = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:innerRect.origin],
                            [NSValue valueWithCGPoint:CGPointMake(innerRect.origin.x+innerRect.size.width, innerRect.origin.y)],
                            [NSValue valueWithCGPoint:CGPointMake(innerRect.origin.x+innerRect.size.width, innerRect.origin.y+innerRect.size.height)],
                            [NSValue valueWithCGPoint:CGPointMake(innerRect.origin.x, innerRect.origin.y+innerRect.size.height)],
                            nil];
        boundedVertex = [ILSCLipper clipSubject:vs withClipper:clipper method:ILSIntersection];
    } else {
        boundedVertex = vs;
        NSLog(@"setupEdgesFor ----- skip for outEdgeWidth %f", _outEdgeWidth);
    }
    
    pView.vertex = [ILSCLipper offsetPloyon:boundedVertex offset:_polygonOffset];
    [pView setupEdges];
}

- (void)setBendPercent:(CGFloat)bendPercent {
    _bendPercent = bendPercent;
    for (ILSPolygonImageView *pView in self.slotViews.allValues) {
        pView.bendPercent = bendPercent;
        [pView setupEdges];
    }
}

- (void)setOutEdgeWidth:(CGFloat)outEdgeWidth {
    _outEdgeWidth = outEdgeWidth;
    NSUInteger index = 0;
    for (NSMutableArray *slotPois in self.slots) {
        ILSPolygonImageView *pView = [self.slotViews objectForKey:[NSNumber numberWithInteger:index]];
        [self setupEdgesFor:pView withSlot:slotPois];
        index ++;
    }
    
    if (_outEdgeWidth > 0.0f && _outEdgeWidth < self.bounds.size.width/2.0f && _outEdgeWidth < self.bounds.size.height/2.0f) {
        CGRect innerRect = CGRectInset(self.bounds, _outEdgeWidth, _outEdgeWidth);
        for (ILSHandView *handView in self.handViews.allValues) {
            handView.clippingRect = innerRect;
        }
    }
}

- (void)setPolygonOffset:(CGFloat)polygonOffset {
    _polygonOffset = polygonOffset;
    NSUInteger index = 0;
    for (NSMutableArray *slotPois in self.slots) {
        ILSPolygonImageView *pView = [self.slotViews objectForKey:[NSNumber numberWithInteger:index]];
        [self setupEdgesFor:pView withSlot:slotPois];
        index ++;
    }
}

- (void)setupVertexWithString: (NSString *) pointStr {
    NSArray *pointsArray = [pointStr componentsSeparatedByString:@","];
    self.vertex = [NSMutableArray arrayWithCapacity:pointsArray.count];
    CGSize size = self.frame.size;
    for (NSString *thePoiStr in pointsArray) {
        NSArray *pa = [thePoiStr componentsSeparatedByString:@":"];
        CGPoint point = CGPointMake([[pa objectAtIndex:0]floatValue], [[pa lastObject]floatValue]);
        point.x *= size.width;
        point.y *= size.height;
        NSLog(@"setupVertexWithString add point %@", NSStringFromCGPoint(point));
        [self.vertex addObject: [NSValue valueWithCGPoint:point]];
    }
}

- (void)setupSlotsWithString: (NSString *) slotStr {
    NSArray *slotArray = [slotStr componentsSeparatedByString:@" / "];
    self.slots = [NSMutableArray arrayWithCapacity:slotArray.count];
    for (NSString * slotString in slotArray) {
        NSArray *pa = [slotString componentsSeparatedByString:@","];
        NSMutableArray *ps = [NSMutableArray arrayWithCapacity:pa.count];
        for (NSString *sp in pa) {
            [ps addObject: [NSNumber numberWithInteger:sp.integerValue]];
        }
        [self.slots addObject:ps];
    }
    NSLog(@"setupSlotsWithString slots is %@", self.slots);
}

- (void)setupPivotsWithString: (NSString *) pivotStr {
    NSArray *pivotArray = [pivotStr componentsSeparatedByString:@" / "];
    self.pivots = [NSMutableArray arrayWithCapacity:pivotArray.count];
    for (NSString *pString in pivotArray) {
        ILSPivot *pivot = [[ILSPivot alloc]initWithVertex:self.vertex pivotString:pString];
        pivot.delegate = self;
        [self.pivots addObject:pivot];
    }
}

- (void)pivot: (ILSPivot *)pivot didMoveVertexWithIndex: (NSArray *)vertex {
    NSUInteger index = 0;
    for (NSMutableArray *slotPois in self.slots) {
        ILSPolygonImageView *pView = [self.slotViews objectForKey:[NSNumber numberWithInteger:index]];
        [self setupEdgesFor:pView withSlot:slotPois];
        index ++;
    }

    for (ILSHandView *handView in self.handViews.allValues) {
        [handView reLocation];
    }
}
@end
