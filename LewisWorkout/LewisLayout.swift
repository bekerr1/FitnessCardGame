//
//  LewisLayout.swift
//  LewisWorkout
//
//  Created by brendan kerr on 6/29/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import Foundation
import UIKit


protocol Layout {
    
    mutating func layout(rect: CGRect)
    
}

protocol Drawable {
    
    func draw(renderer: Renderer)
}

protocol Pathable {
    
    func drawWithPath() -> CGMutablePath
}


protocol Renderer {
    
    func startAtPoint(point: CGPoint)
    func addSingleCurve(controlPoint: CGPoint, EndingPoint endPoint: CGPoint)
    func addDoubleCurve(controlPoint1: CGPoint, ControlPointTwo controlPoint2: CGPoint, EndingPoint endPoint: CGPoint)
    func beginRender()
    func endRender()
    
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

extension CGContext: Renderer {
    
    func beginRender() {
        CGContextBeginPath(self)
    }
    
    func endRender() {
        CGContextClosePath(self)
    }
    
    func startAtPoint(point: CGPoint) {
        CGContextMoveToPoint(self, point.x, point.y)
    }
    
    func addSingleCurve(controlPoint: CGPoint, EndingPoint endPoint: CGPoint) {
        CGContextAddQuadCurveToPoint(self, controlPoint.x, controlPoint.y, endPoint.x, endPoint.y)
    }
    
    func addDoubleCurve(controlPoint1: CGPoint, ControlPointTwo controlPoint2: CGPoint, EndingPoint endPoint: CGPoint) {
        //Not needed now
    }
}