//
//  ILSPivot.h
//  ImageTest
//
//  Created by 周和生 on 13-5-28.
//  Copyright (c) 2013年 周和生. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ILSPivotDirectionHorizontal,
    ILSPivotDirectionVertical,
    ILSPivotDirectionHorizontalDia,
    ILSPivotDirectionVerticalDia,
    ILSPivotDirectionAny
} ILSPivotDirection;


@class ILSPivot;

@protocol ILSPivotDelegate <NSObject>
@required
- (void)pivot: (ILSPivot *)pivot didMoveVertexWithIndex: (NSArray *)vertex;

@end

@interface ILSPivot : NSObject {
    NSUInteger _startPositonIndex, _endPositonIndex;
    CGFloat _postionPercent;
    
    ILSPivotDirection _direction;
    NSUInteger _startLimitIndex, _endLimitIndex;
}
@property (nonatomic, weak) NSObject<ILSPivotDelegate> * delegate;
@property (nonatomic, assign) CGRect clippingRect;
@property (nonatomic, strong) NSMutableArray *vertex;
@property (nonatomic, strong) NSMutableArray *indexOfVertexToMove;
@property (nonatomic, readonly) CGPoint handViewCenter;
@property (nonatomic, readonly) ILSPivotDirection direction;

- (id)initWithVertex: (NSMutableArray *)vtx pivotString: (NSString *)pstring;
- (void)handleMovement: (CGSize)movement;
@end
