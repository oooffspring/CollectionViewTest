//
//  BasicLayoutItem.m
//  CollectionViewTest
//
//  Created by xiezilong on 6/8/13.
//  Copyright (c) 2013 xiezilong. All rights reserved.
//

#import "BasicLayoutItem.h"

@implementation BasicLayoutItem

-(id)initWithIndex:(NSInteger)index
    NumbersOfSlots:(NSInteger)numbersOfSlots
              Type:(NSString*)type
      PointsString:(NSString*)pointsString
       SlotsString:(NSString*)slotsString
     PolygonString:(NSString*)polygonString
{
    //初始化
    self = [self init];
    if (self) {
        self.index = index;
        self.numberOfSlots = numbersOfSlots;
        self.type = type;
        self.pointsString = pointsString;
        self.slotsString = slotsString;
        self.polygonString = polygonString;
        [self setup];
    }
    return self;
}

- (void)setup
{
    [self setupVertexWithString:self.pointsString];
    [self setupSlotsWithString:self.slotsString];
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


@end
