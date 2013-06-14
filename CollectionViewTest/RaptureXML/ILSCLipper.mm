//
//  CLipperTester.m
//  ImageTest
//
//  Created by 周和生 on 13-5-24.
//  Copyright (c) 2013年 周和生. All rights reserved.
//

#include "clipper.hpp"
#import "ILSCLipper.h"
#include <iostream>

using namespace ClipperLib;

//
// Cohen-Sutherland line clipping
//
// Source: http://en.wikipedia.org/wiki/Cohen-Sutherland
//

typedef int OutCode;

const int INSIDE = 0; // 0000
const int LEFT = 1;   // 0001
const int RIGHT = 2;  // 0010
const int BOTTOM = 4; // 0100
const int TOP = 8;    // 1000

// Compute the bit code for a point (x, y) using the clip rectangle
// bounded diagonally by (xmin, ymin), and (xmax, ymax)

OutCode ComputeOutCode(CGFloat x, CGFloat y, CGFloat xmin, CGFloat ymin, CGFloat xmax, CGFloat ymax)
{
    OutCode code;
    
    code = INSIDE;          // initialised as being inside of clip window
    if (x < xmin) code |= LEFT;          // to the left of clip window
    else if (x > xmax) code |= RIGHT;     // to the right of clip window
        
    if (y < ymin) code |= BOTTOM;          // below the clip window
    else if (y > ymax) code |= TOP;     // above the clip window
        
    
    return code;
}

// Cohen–Sutherland clipping algorithm clips a line from
// P0 = (x0, y0) to P1 = (x1, y1) against a rectangle with
// diagonal from (xmin, ymin) to (xmax, ymax).
bool CohenSutherlandLineClip(CGFloat &x0, CGFloat &y0, CGFloat &x1, CGFloat &y1, CGFloat xmin, CGFloat ymin, CGFloat xmax, CGFloat ymax)
{
    // compute outcodes for P0, P1, and whatever point lies outside the clip rectangle
    OutCode outcode0 = ComputeOutCode(x0, y0, xmin, ymin, xmax, ymax);
    OutCode outcode1 = ComputeOutCode(x1, y1, xmin, ymin, xmax, ymax);
    bool accept = false;
    
    while (true) {
        if (!(outcode0 | outcode1)) { // Bitwise OR is 0. Trivially accept and get out of loop
            accept = true;
            break;
        } else if (outcode0 & outcode1) { // Bitwise AND is not 0. Trivially reject and get out of loop
            break;
        } else {
            // failed both tests, so calculate the line segment to clip
            // from an outside point to an intersection with clip edge
            double x, y;
            
            // At least one endpoint is outside the clip rectangle; pick it.
            OutCode outcodeOut = outcode0 ? outcode0 : outcode1;
            
            // Now find the intersection point;
            // use formulas y = y0 + slope * (x - x0), x = x0 + (1 / slope) * (y - y0)
            if (outcodeOut & TOP) {           // point is above the clip rectangle
                x = x0 + (x1 - x0) * (ymax - y0) / (y1 - y0);
                y = ymax;
            } else if (outcodeOut & BOTTOM) { // point is below the clip rectangle
                x = x0 + (x1 - x0) * (ymin - y0) / (y1 - y0);
                y = ymin;
            } else if (outcodeOut & RIGHT) {  // point is to the right of clip rectangle
                y = y0 + (y1 - y0) * (xmax - x0) / (x1 - x0);
                x = xmax;
            } else if (outcodeOut & LEFT) {   // point is to the left of clip rectangle
                y = y0 + (y1 - y0) * (xmin - x0) / (x1 - x0);
                x = xmin;
            }
            
            // Now we move outside point to intersection point to clip
            // and get ready for next pass.
            if (outcodeOut == outcode0) {
                x0 = x;
                y0 = y;
                outcode0 = ComputeOutCode(x0, y0, xmin, ymin, xmax, ymax);
            } else {
                x1 = x;
                y1 = y;
                outcode1 = ComputeOutCode(x1, y1, xmin, ymin, xmax, ymax);
            }
        }
    }
    
    return accept;
}


ClipType convertClipType(ILSCLipType ilsClipType) {
    switch (ilsClipType) {
        case ILSIntersection:
            return ctIntersection;
            break;
        case ILSDifference:
            return ctDifference;
            break;
        case ILSUnion:
            return ctUnion;
            break;
        case ILSXor:
            return ctXor;
            break;
        default:
            return ctUnion;
            break;
    }
}

@implementation ILSCLipper

+ (BOOL) clipLineWithRect: (CGRect)rect start: (CGPoint *)startPoint end: (CGPoint *)endPoint {
    
    return CohenSutherlandLineClip(startPoint->x, startPoint->y, endPoint->x, endPoint->y,
                                   rect.origin.x, rect.origin.y, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);
}


+ (NSArray *)clipSubject: (NSArray *)subjectVertex withClipper: (NSArray *)clipperVertex method:(ILSCLipType)clipType {
    //NSLog(@"ILSCLipper clipSubject %@ with %@", subjectVertex, clipperVertex);
    Polygon subject, clip;
    Polygons solution;
    
    for (NSValue *value in subjectVertex) {
        CGPoint point;
        [value getValue:&point];
        subject.push_back(IntPoint((long64)point.x, (long64)point.y));
    }
    
    for (NSValue *value in clipperVertex) {
        CGPoint point;
        [value getValue:&point];
        clip.push_back(IntPoint((long64)point.x, (long64)point.y));
    }
    
    Clipper c;
	c.AddPolygon(subject, ptSubject);
	c.AddPolygon(clip, ptClip);
	c.Execute(convertClipType(clipType), solution);

    if (solution.size()) {
        //std::cout << "ILSCLipper result is:\n" << solution[0];
        
        Polygon firstSolution = solution[0];
        int size = firstSolution.size();
        
        NSMutableArray *result = [NSMutableArray arrayWithCapacity:size];
        for (int i=0; i<size; i++) {
            IntPoint p = firstSolution[i];
            [result addObject:[NSValue valueWithCGPoint:CGPointMake((CGFloat)p.X, (CGFloat)p.Y)]];
        }
        return result;

    } else {
        //NSLog(@"ILSCLipper result ploygons zero");
        return nil;
    }
}

+ (NSArray *)offsetPloyon: (NSArray *)subjectVertex offset: (CGFloat)offset {
    Polygons subject(1), solution;
    for (NSValue *value in subjectVertex) {
        CGPoint point;
        [value getValue:&point];
        subject[0].push_back(IntPoint((long64)point.x, (long64)point.y));
    }
    
    OffsetPolygons(subject, solution, offset);
    if (solution.size()) {
        //std::cout << "ILSCLipper offset result is:\n" << solution[0];
        
        Polygon firstSolution = solution[0];
        int size = firstSolution.size();
        
        NSMutableArray *result = [NSMutableArray arrayWithCapacity:size];
        for (int i=0; i<size; i++) {
            IntPoint p = firstSolution[i];
            [result addObject:[NSValue valueWithCGPoint:CGPointMake((CGFloat)p.X, (CGFloat)p.Y)]];
        }
        return result;
        
    } else {
        //NSLog(@"ILSCLipper offset result ploygons zero");
        return nil;
    }
}


+ (void)testCLipper {
	
	Polygons subj(2), clip(1), solution, offset, simple;
    
#define __CLIPLINE__
#ifdef __CLIPLINE__
    subj[0].push_back(IntPoint(0,0));
    subj[0].push_back(IntPoint(100,100));
    // comment to test clip line
    subj[0].push_back(IntPoint(0,100));
    
    clip[0].push_back(IntPoint(10,10));
	clip[0].push_back(IntPoint(10,20));
	clip[0].push_back(IntPoint(20,20));
	clip[0].push_back(IntPoint(20,10));
    std::cout << "subj\n" << subj;
    std::cout << "clip\n" << clip;
    
	//perform intersection ...
	Clipper c;
	c.AddPolygons(subj, ptSubject);
	c.AddPolygons(clip, ptClip);
	c.Execute(ctDifference, solution, pftNonZero, pftNonZero);
    
    std::cout << "solution\n" << solution;
    
    CGPoint start = CGPointMake(0, 0);
    CGPoint end = CGPointMake(100, 90);
    CGRect rect = CGRectMake(10, 10, 10, 10);
    BOOL clipped = [self clipLineWithRect:rect start:&start end:&end];
    NSLog(@"line cliped result %d result %@ %@", clipped, NSStringFromCGPoint(start), NSStringFromCGPoint(end));

#else
	//define outer blue 'subject' polygon
	subj[0].push_back(IntPoint(180,200));
	subj[0].push_back(IntPoint(260,200));
	subj[0].push_back(IntPoint(260,150));
	subj[0].push_back(IntPoint(180,150));
	
	//define subject's inner triangular 'hole' (with reverse orientation)
	subj[1].push_back(IntPoint(215,160));
	subj[1].push_back(IntPoint(230,190));
	subj[1].push_back(IntPoint(200,190));
	
	//define orange 'clipping' polygon
	clip[0].push_back(IntPoint(190,210));
	clip[0].push_back(IntPoint(240,210));
	clip[0].push_back(IntPoint(240,130));
	clip[0].push_back(IntPoint(190,130));
    
    std::cout << "subj\n" << subj;
    std::cout << "clip\n" << clip;
    
	//perform intersection ...
	Clipper c;
	c.AddPolygons(subj, ptSubject);
	c.AddPolygons(clip, ptClip);
	c.Execute(ctIntersection, solution, pftNonZero, pftNonZero);
    
    std::cout << "solution\n" << solution;
#endif
    
    OffsetPolygons(solution, offset, 10, jtRound);
    std::cout << "offset\n" << offset;
    
    SimplifyPolygons(solution, simple);
    std::cout << "simple\n" << simple;
    
    std::cout << "finished testCLipper -------------";
}

@end
