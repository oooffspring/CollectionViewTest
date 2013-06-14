//
//  BasicLayoutItem.h
//  CollectionViewTest
//
//  Created by xiezilong on 6/8/13.
//  Copyright (c) 2013 xiezilong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BasicLayoutItem : NSObject

-(id)initWithIndex:(NSInteger)index
    NumbersOfSlots:(NSInteger)numbersOfSlots
              Type:(NSString*)type
      PointsString:(NSString*)pointsString
       SlotsString:(NSString*)slotsString
     PolygonString:(NSString*)polygonString;

@property (nonatomic) NSInteger index, numberOfSlots;
@property (nonatomic, strong) NSString *type, *pointsString, *slotsString, *polygonString;
@property (nonatomic, strong) NSMutableArray *vertex, *slots;
@property (nonatomic) CGRect frame;

@end
