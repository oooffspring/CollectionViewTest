//
//  CLipperTester.h
//  ImageTest
//
//  Created by 周和生 on 13-5-24.
//  Copyright (c) 2013年 周和生. All rights reserved.
//
#import "ILSDefines.h"
#import <Foundation/Foundation.h>

@interface ILSCLipper : NSObject

+ (BOOL) clipLineWithRect: (CGRect)rect start: (CGPoint *)startPoint end: (CGPoint *)endPoint;
+ (NSArray *)clipSubject: (NSArray *)subjectVertex withClipper: (NSArray *)clipperVertex method: (ILSCLipType)clipType;
+ (NSArray *)offsetPloyon: (NSArray *)subjectVertex offset: (CGFloat)offset;


+ (void)testCLipper;
@end
