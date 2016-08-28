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
    let alignHorizGradient = CAGradientLayer()
    let alignVertGradient = CAGradientLayer()
    let containerLayer = CALayer()
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.layer.cornerRadius = LewisGeometricConstants.cornerRadius
    }
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.layer.cornerRadius = LewisGeometricConstants.cornerRadius
        addAlignmentGradient()
    }
    
    func addAlignmentGradient() {
        
        alignHorizGradient.frame = CGRectMake(0, 0, 90, 90)
        alignHorizGradient.locations = [0.0, 0.2, 0.8, 1.0]
        alignHorizGradient.colors = [UIColor.clearColor().CGColor, UIColor.clearColor().CGColor, UIColor.clearColor().CGColor, UIColor.clearColor().CGColor]
        alignHorizGradient.startPoint = CGPointMake(0.0, 0.5)
        alignHorizGradient.endPoint = CGPointMake(1.0, 0.5)
        
        alignVertGradient.frame = CGRectMake(0, 0, 90, 90)
        alignVertGradient.locations = [0.0, 0.2, 0.8, 1.0]
        alignVertGradient.colors = [UIColor.clearColor().CGColor, UIColor.clearColor().CGColor, UIColor.clearColor().CGColor, UIColor.clearColor().CGColor]
        
        containerLayer.frame = CGRectMake(0, 0, 90, 90)
        containerLayer.position = CGPointMake(frame.width/2, frame.height/2)
        containerLayer.backgroundColor = UIColor.clearColor().CGColor
        
        containerLayer.addSublayer(alignHorizGradient)
        containerLayer.addSublayer(alignVertGradient)
        
        layer.addSublayer(containerLayer)
        
    }
    
    func showAlignmentGradient() {
        
        let fromColors = alignHorizGradient.colors
        let toColors = [UIColor.blackColor().CGColor, UIColor.clearColor().CGColor, UIColor.clearColor().CGColor, UIColor.blackColor().CGColor]
        
        let alignAnimation = CABasicAnimation(keyPath: "colors")
        alignAnimation.fromValue = fromColors
        alignAnimation.toValue = toColors
        alignAnimation.duration = 1.0
        alignAnimation.removedOnCompletion = true
        alignAnimation.fillMode = kCAFillModeBoth
        alignAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        let fromColor = containerLayer.backgroundColor
        let toColor = UIColor.blackColor().colorWithAlphaComponent(0.5).CGColor
        
        let containerAnimation = CABasicAnimation(keyPath: "backgroundColor")
        containerAnimation.fromValue = fromColor
        containerAnimation.toValue = toColor
        containerAnimation.duration = 1.0
        containerAnimation.removedOnCompletion = true
        containerAnimation.fillMode = kCAFillModeBoth
        containerAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        alignHorizGradient.colors = toColors
        alignVertGradient.colors = toColors
        
        containerLayer.backgroundColor = toColor
        
        alignHorizGradient.addAnimation(alignAnimation, forKey:"animateHorizGradient")
        alignVertGradient.addAnimation(alignAnimation, forKey:"animateVertGradient")
        containerLayer.addAnimation(containerAnimation, forKey: "backgroundColor")
    }
    
    func hideAlignmentGradient() {
        
        let fromColors = alignHorizGradient.colors
        let toColors = [UIColor.clearColor().CGColor, UIColor.clearColor().CGColor, UIColor.clearColor().CGColor, UIColor.clearColor().CGColor]
        
        let alignAnimation = CABasicAnimation(keyPath: "colors")
        alignAnimation.fromValue = fromColors
        alignAnimation.toValue = toColors
        alignAnimation.duration = 1.0
        alignAnimation.removedOnCompletion = true
        alignAnimation.fillMode = kCAFillModeBoth
        alignAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        let fromColor = containerLayer.backgroundColor
        let toColor = UIColor.clearColor().CGColor
        
        let containerAnimation = CABasicAnimation(keyPath: "backgroundColor")
        containerAnimation.fromValue = fromColor
        containerAnimation.toValue = toColor
        containerAnimation.duration = 1.0
        containerAnimation.removedOnCompletion = true
        containerAnimation.fillMode = kCAFillModeBoth
        containerAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)

        alignHorizGradient.colors = toColors
        alignVertGradient.colors = toColors
        
        containerLayer.backgroundColor = toColor
        
        alignHorizGradient.addAnimation(alignAnimation, forKey:"animateHorizGradient")
        alignVertGradient.addAnimation(alignAnimation, forKey:"animateVertGradient")
        containerLayer.addAnimation(containerAnimation, forKey: "backgroundColor")
    }
    
    
    
    func createStackEffect() {
        
        //print("Reference rect = \(NSStringFromCGRect(referenceRect))")
        
        var xOffset: CGFloat = 30.0
        for _ in 0..<7 {
            
            let rectOffset = CGRectOffset(self.bounds, 0.0, xOffset)
            
            print("Offset rect = \(NSStringFromCGRect(rectOffset))")
            
            let shapePath = UIBezierPath(roundedRect: rectOffset, cornerRadius: LewisGeometricConstants.cornerRadius)
            let shapeLayer: CAShapeLayer = CAShapeLayer()
            shapeLayer.path = shapePath.CGPath
            shapeLayer.strokeColor = UIColor.blackColor().CGColor
            shapeLayer.lineWidth = 1.0
            shapeLayer.fillColor = UIColor.whiteColor().CGColor
            
            cardSublayers.append(shapeLayer)
            self.layer.addSublayer(shapeLayer)
            
            xOffset -= 5.0
        }
        
//        squareLayer.contents = squareImage.CGImage
//        squareLayer.frame = CGRectMake(0, 0, 90, 90)
//        squareLayer.backgroundColor = UIColor.clearColor().CGColor
//        squareLayer.position = CGPointMake(frame.size.width/2, frame.size.height/2)
//        layer.addSublayer(squareLayer)
        
    }
    
    
    
    func convertCenterOfSquareToView(view: UIView) -> CGPoint {
        
        return convertPoint(containerLayer.position, toView: view)
    }
    
    
}
