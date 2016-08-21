//
//  LWDeckPlaceholderView.swift
//  LewisWorkout
//
//  Created by brendan kerr on 6/21/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class LWDeckPlaceholderView: UIView {
    
    
    var cardSublayers: [CAShapeLayer] = Array()
    var referenceRect: CGRect = CGRect()
    let squareImage: UIImage = UIImage(named: "squarePNG")!
    var squareLayer: CALayer = CALayer()
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.layer.cornerRadius = LewisGeometricConstants.cornerRadius
        //self.layer.backgroundColor = UIColor.redColor().CGColor
    }
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.layer.cornerRadius = LewisGeometricConstants.cornerRadius
    }
    
//    override func drawRect(rect: CGRect) {
//        print(#function)
//        //createStackEffect()
//        //setNeedsDisplay()
//    }
//    
    
    
    
    func createStackEffect() {
        
        //print("Reference rect = \(NSStringFromCGRect(referenceRect))")
        
        var xOffset: CGFloat = 30.0
        for _ in 0..<8 {
            
            let rectOffset = CGRectOffset(self.bounds, 0.0, xOffset)
            
            print("Offset rect = \(NSStringFromCGRect(rectOffset))")
            
            let shapePath = UIBezierPath(roundedRect: rectOffset, cornerRadius: LewisGeometricConstants.cornerRadius)
            let shapeLayer: CAShapeLayer = CAShapeLayer()
            shapeLayer.path = shapePath.CGPath
            shapeLayer.strokeColor = UIColor.blackColor().CGColor
            shapeLayer.lineWidth = 1.0
            shapeLayer.fillColor = UIColor.grayColor().CGColor
            
            cardSublayers.append(shapeLayer)
            self.layer.addSublayer(shapeLayer)
            
            xOffset -= 5.0
        }
        
        squareLayer.contents = squareImage.CGImage
        squareLayer.frame = CGRectMake(0, 0, 90, 90)
        squareLayer.backgroundColor = UIColor.clearColor().CGColor
        squareLayer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        self.layer.addSublayer(squareLayer)
        
    }
    
    
    func convertCenterOfSquareToView(view: UIView) -> CGPoint {
        
        return self.convertPoint(squareLayer.position, toView: view)
    }
    
    
}
