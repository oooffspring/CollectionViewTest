//
//  ILSPivot.m
//  ImageTest
//
//  Created by 周和生 on 13-5-28.
//  Copyright (c) 2013年 周和生. All rights reserved.
//

#import "ILSPivot.h"
#import "ILSCLipper.h"

@implementation ILSPivot


- (void)handleMovement: (CGSize)movement {
    CGFloat dx, dy;
    dx = movement.width;
    dy = movement.height;
    
    CGPoint limit1, limit2;
    [[self.vertex objectAtIndex:_startLimitIndex]getValue:&limit1];
    [[self.vertex objectAtIndex:_endLimitIndex]getValue:&limit2];
    
    BOOL canMoveAll = YES;
    CGSize size = CGSizeZero;
    
    switch (_direction) {
        case ILSPivotDirectionHorizontal:
        case ILSPivotDirectionHorizontalDia:
            // test canMoveAll
            for (NSNumber *index in self.indexOfVertexToMove) {
                CGPoint p;
                [[self.vertex objectAtIndex:index.integerValue]getValue:&p];
                p.x += dx;
                if (p.x>MAX(limit1.x, limit2.x) || p.x<MIN(limit1.x, limit2.x)) {
                    canMoveAll = NO;
                    break;
                }
            }
            
            if (canMoveAll) {
                size.width = dx;
            }
            break;
            
        case ILSPivotDirectionVertical:
        case ILSPivotDirectionVerticalDia:
            // test canMoveAll
            for (NSNumber *index in self.indexOfVertexToMove) {
                CGPoint p;
                [[self.vertex objectAtIndex:index.integerValue]getValue:&p];
                p.y += dy;
                if (p.y>MAX(limit1.y, limit2.y) || p.y<MIN(limit1.y, limit2.y)) {
                    canMoveAll = NO;
                    break;
                }
            }
            
            if (canMoveAll) {
                size.height = dy;
            }  
            break;
            
            
        default:
            // ANY
            // test canMoveAll
            for (NSNumber *index in self.indexOfVertexToMove) {
                CGPoint p;
                [[self.vertex objectAtIndex:index.integerValue]getValue:&p];
                p.x += dx;
                p.y += dy;
                if (p.x>MAX(limit1.x, limit2.x) || p.x<MIN(limit1.x, limit2.x) || p.y>MAX(limit1.y, limit2.y) || p.y<MIN(limit1.y, limit2.y)) {
                    canMoveAll = NO;
                    break;
                }
            }
            
            if (canMoveAll) {
                size.width = dx;
                size.height = dy;
            }
            break;
    }
    
    // now perform move all points
    BOOL isFirstPoint = YES;
    for (NSNumber *index in self.indexOfVertexToMove) {
        NSUInteger i = index.integerValue;
        NSValue *value = [self.vertex objectAtIndex:i];
        
        CGPoint p;
        [value getValue:&p];
        
        p.x += size.width;
        p.y += size.height;
        
        
        if (_direction == ILSPivotDirectionHorizontalDia && isFirstPoint) {
            // for Horizontal DIA, calculate p.y with p.x along with limit points
            // only the first point can move with DIA
            p.y = limit1.y + (limit2.y-limit1.y)*(p.x-limit1.x)/(limit2.x-limit1.x);
        }
        
        if (_direction == ILSPivotDirectionVerticalDia  && isFirstPoint) {
            // for Vertical DIA, calculate p.x with p.y along with limit points
            // only the first point can move with DIA
            p.x = limit1.x + (limit2.x-limit1.x)*(p.y-limit1.y)/(limit2.y-limit1.y);
        }
        
        [self.vertex replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:p]];        
        isFirstPoint = NO;
    }
    
    [self.delegate pivot:self didMoveVertexWithIndex:self.indexOfVertexToMove];
   
}

- (CGPoint)handViewCenter {
    NSValue *v1 = [self.vertex objectAtIndex:_startPositonIndex];
    NSValue *v2 = [self.vertex objectAtIndex:_endPositonIndex];
    CGPoint p1, p2;
    [v1 getValue:&p1];
    [v2 getValue:&p2];
    
    [ILSCLipper clipLineWithRect:_clippingRect start:&p1 end:&p2];
    
    CGPoint p;
    p.x = p1.x*(1.0f - _postionPercent) + p2.x*_postionPercent;
    p.y = p1.y*(1.0f - _postionPercent) + p2.y*_postionPercent;
    
    return p;
}

- (id)initWithVertex: (NSMutableArray *)vtx pivotString: (NSString *)pstring {
    if (self = [super init]) {
        NSArray *components = [pstring componentsSeparatedByString:@":"];
        if (components.count==5) {
            // positions
            NSString *posStrings = [components objectAtIndex:0];
            NSArray *posArray = [posStrings componentsSeparatedByString:@","];
            _startPositonIndex = [[posArray objectAtIndex:0]integerValue];
            _endPositonIndex = [[posArray objectAtIndex:1]integerValue];
            
            // position percent
            _postionPercent = [[components objectAtIndex:1]floatValue];
            
            // direction
            _direction = [self convertToDirection: [components objectAtIndex:2]];
            
            // limits
            NSString *limitString = [components objectAtIndex:3];
            NSArray *limitArray = [limitString componentsSeparatedByString:@"-"];
            _startLimitIndex = [[limitArray objectAtIndex:0]integerValue];
            _endLimitIndex = [[limitArray objectAtIndex:1]integerValue];
            
            NSString *pMoveString = [components objectAtIndex:4];
            NSArray *pMoveArray = [pMoveString componentsSeparatedByString:@","];
            self.indexOfVertexToMove = [NSMutableArray arrayWithCapacity: pMoveArray.count];
            for (NSString *indexStr in pMoveArray) {
                [self.indexOfVertexToMove addObject:[NSNumber numberWithInteger:indexStr.integerValue]];
            }
        } else {
            NSLog(@"initWithPivotString pstring maybe error %@", pstring);
        }
                                   
        self.vertex = vtx;
    }
    return self;
}

- (ILSPivotDirection)convertToDirection:(NSString *)directionString {
    if ([directionString isEqualToString:@"H"]) {
        return ILSPivotDirectionHorizontal;
    }
    if ([directionString isEqualToString:@"V"]) {
        return ILSPivotDirectionVertical;
    }
    if ([directionString isEqualToString:@"H-DIA"]) {
        return ILSPivotDirectionHorizontalDia;
    }
    if ([directionString isEqualToString:@"V-DIA"]) {
        return ILSPivotDirectionVerticalDia;
    }
    
    return ILSPivotDirectionAny;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"start %d end %d percent %f direction %d limit %d-%d pointsToMove: %@ vertext %@", _startPositonIndex, _endPositonIndex, _postionPercent, _direction, _startLimitIndex, _endLimitIndex, self.indexOfVertexToMove, self.vertex];
}

@end
