//
//  LewisClassicalCardShapes.swift
//  LewisWorkout
//
//  Created by brendan kerr on 6/29/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import Foundation
import UIKit


/*
 A file where classic card shapes are kept: Each shape has a set of points.  Depending on the shape, the points will be drawn different ways to the screen.  You must initialize the structs with an array of points.  The draw method is given a renderer which will be used to draw to the screen.
 
*/



protocol Pathable {
    
    func drawPathWithDesign(design: HeartDesign) -> CGMutablePath
}


protocol PathRenderer {
    
    
    func startAtPoint(point: CGPoint)
    func addSingleCurve(controlPoint: CGPoint, EndingPoint endPoint: CGPoint)
    func addDoubleCurve(controlPoint1: CGPoint, ControlPointTwo controlPoint2: CGPoint, EndingPoint endPoint: CGPoint)
    func endRender()
    
}



extension CGMutablePath : PathRenderer {
    
    
    func endRender() {
        CGPathCloseSubpath(self)
    }
    
    func startAtPoint(point: CGPoint) {
        CGPathMoveToPoint(self, nil, point.x, point.y)
    }
    
    func addSingleCurve(controlPoint: CGPoint, EndingPoint endPoint: CGPoint) {
        CGPathAddQuadCurveToPoint(self, nil, controlPoint.x, controlPoint.y, endPoint.x, endPoint.y)
    }
    
    func addDoubleCurve(controlPoint1: CGPoint, ControlPointTwo controlPoint2: CGPoint, EndingPoint endPoint: CGPoint) {
        //Not needed now
    }
    
    
}




protocol Shapeable  {
    
    func thisShape() -> CAShapeLayer
    
}




struct HeartDesign {
    
    let bottomPoint: CGPoint
    let leftArcControl: CGPoint
    let topPoint: CGPoint
    let rightArcControl: CGPoint
    
    init(_ b: CGPoint, _ lac: CGPoint, _ t: CGPoint, _ rac: CGPoint) {
        bottomPoint = b
        leftArcControl = lac
        topPoint = t
        rightArcControl = rac
    }
}



struct Heart: Pathable, Shapeable {
    
    //typealias Shape = CAShapeLayer
    
    let shape: CAShapeLayer
    var suitSize: CGSize
    
    init() {
        
        suitSize = CGSizeMake(LewisGeometricConstants.suitSizeWidth, LewisGeometricConstants.suitSizeHeight)
        shape = CAShapeLayer()
        shape.frame = CGRectMake(0, 0, LewisGeometricConstants.suitSizeWidth, LewisGeometricConstants.suitSizeHeight)
        
        createHeartDesign()
    }
    
    
    func drawPathWithDesign(design: HeartDesign) -> CGMutablePath {
        
        let path = CGPathCreateMutable()
        path.startAtPoint(design.bottomPoint)
        path.addSingleCurve(design.leftArcControl, EndingPoint: design.topPoint)
        path.addSingleCurve(design.rightArcControl, EndingPoint: design.bottomPoint)
        CGPathCloseSubpath(path)
        return path
    }
    
    func createHeartDesign() {
        
        let bottomPoint = CGPointMake(suitSize.width / 2, suitSize.height)
        let leftControl = CGPointMake(0, 0)
        let topPoint = CGPointMake(suitSize.width / 2, suitSize.height / 2)
        let rightControl = CGPointMake(suitSize.width,0)
        
        print("\(NSStringFromCGPoint(bottomPoint)), \(NSStringFromCGPoint(leftControl)), \(NSStringFromCGPoint(topPoint)), \(NSStringFromCGPoint(rightControl))")
        
        let heartDesign = HeartDesign(bottomPoint, leftControl, topPoint, rightControl)
        let heartPath = drawPathWithDesign(heartDesign)
        
        shape.path = heartPath
        
    
    }
    
    
    func thisShape() -> CAShapeLayer {
        return self.shape
    }
    
    
    
}




struct Diamond {
    
    
    
}
