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

struct Heart: Drawable, Pathable {
    
    let design: HeartDesign
    
    init(WithDesign d: HeartDesign) {
        design = d
    }
    
    func draw(render: Renderer) {
        render.beginRender()
        render.startAtPoint(design.bottomPoint)
        render.addSingleCurve(design.leftArcControl, EndingPoint: design.topPoint)
        render.addSingleCurve(design.rightArcControl, EndingPoint: design.bottomPoint)
        render.endRender()
    }
    
    func drawWithPath() -> CGMutablePath {
        
        let path = CGPathCreateMutable()
        path.startAtPoint(design.bottomPoint)
        path.addSingleCurve(design.leftArcControl, EndingPoint: design.topPoint)
        path.addSingleCurve(design.rightArcControl, EndingPoint: design.bottomPoint)
        CGPathCloseSubpath(path)
        return path
    }
}




struct Diamond {
    
    
    
}
