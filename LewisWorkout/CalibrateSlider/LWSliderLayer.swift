//
//  LWSliderLayer.swift
//  Calibrate Slider
//
//  Created by brendan kerr on 7/21/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit
import QuartzCore

class LWSliderLayer: CALayer {
    
    let ridgeShape1 = CAShapeLayer()
    let ridgeShape2 = CAShapeLayer()
    let ridgeShape3 = CAShapeLayer()
    let gradient = CAGradientLayer()
    
    var sliding: Bool = false
    var touched: Bool = false
    
    override init() {
        //Generic init
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
    }
    
    
    override func drawInContext(ctx: CGContext) {
        //Context Drawing
        
    }
    
    func configRidges() {
        
        let ridge = UIBezierPath(roundedRect: CGRectMake(0, 0, 3, self.frame.height - 6), cornerRadius: 10)
        let thrid = self.frame.width / 4
        ridgeShape1.path = ridge.CGPath
        ridgeShape1.position = CGPointMake(thrid, 3)
        ridgeShape1.fillColor = UIColor(white: 0.3, alpha: 0.9).CGColor
        
        ridgeShape2.path = ridge.CGPath
        ridgeShape2.position = CGPointMake(thrid * 2, 3)
        ridgeShape2.fillColor = UIColor(white: 0.3, alpha: 0.9).CGColor
        
        ridgeShape3.path = ridge.CGPath
        ridgeShape3.position = CGPointMake(thrid * 3, 3)
        ridgeShape3.fillColor = UIColor(white: 0.3, alpha: 0.9).CGColor
        
        //let color2 = UIColor.init(white: 0.30, alpha: 0.85)
        let color3 = UIColor.init(white: 0.15, alpha: 1.0)
        
        gradient.colors = [color3.CGColor, color3.CGColor]
        gradient.locations = [0.0, 0.95]
        gradient.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        gradient.position = CGPointMake(self.frame.width/2, self.frame.height/2)
        gradient.setAffineTransform(CGAffineTransformMakeRotation(CGFloat(M_PI) * 1.5))
        gradient.cornerRadius = 5
        
        self.addSublayer(gradient)
        
    }
    
    
    func animateSliderBack(To position: CGPoint) {
        
        self.speed = 1.0
        
        let sliderBackAnimation = CABasicAnimation(keyPath: "origin")
        sliderBackAnimation.duration = 3.0
        sliderBackAnimation.fromValue = NSValue.init(CGPoint: self.position)
        sliderBackAnimation.toValue = NSValue.init(CGPoint: position)
        self.addAnimation(sliderBackAnimation, forKey: "origin")
    
        self.frame.origin = position
        
    }
    
    func slowLayerAnimation(timer: NSTimer) {
        print("Timer HIt")
        self.speed = 0.5
        
    }

}
