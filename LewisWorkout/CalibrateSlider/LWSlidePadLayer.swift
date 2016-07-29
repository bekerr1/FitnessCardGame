//
//  LWSlidePadLayer.swift
//  Calibrate Slider
//
//  Created by brendan kerr on 7/21/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit
import QuartzCore

class LWSlidePadLayer: CALayer {
    
    let gradient = CAGradientLayer()
    let gradient1 = CAGradientLayer()
    
    override init() {
        //Generic init
        super.init()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func drawInContext(ctx: CGContext) {
        //Context Drawing
        
    }
    
    func configGradient() {
        
        let color1 = UIColor.init(white: 0.45, alpha: 1.0)
        let color15 = UIColor.init(white: 0.55, alpha: 0.85)
        //let color2 = UIColor.init(white: 0.75, alpha: 0.85)
        let color3 = UIColor.init(white: 0.05, alpha: 1.0)
        
        gradient.colors = [color3.CGColor, color1.CGColor, color15.CGColor, color15.CGColor, color1.CGColor, color3.CGColor]
        gradient.locations = [0.0, 0.20, 0.4, 0.6, 0.80, 1.0]
        gradient.frame = CGRectMake(0, 0, self.frame.width - 0.5, self.frame.height - 1)
        gradient.position = CGPointMake(self.frame.width/2, self.frame.height/2)
        gradient.cornerRadius = 10.0
        
        self.addSublayer(gradient)
    }

}
