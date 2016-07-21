//
//  LewisGameView.swift
//  LewisWorkout
//
//  Created by brendan kerr on 7/20/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class LewisGameView: UIView {
    
    var decorationLayer: CALayer = CALayer()
    let widthOffset: CGFloat = 0
    let heightOffset: CGFloat = 210
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    override func drawRect(rect: CGRect) {
        //drawing code
        
    }
    
    func configureDecorationLayer() {
        print("Game view frame: \(NSStringFromCGRect(self.frame))")
        
        decorationLayer.frame = CGRectMake(0, 0, self.frame.width - widthOffset, self.frame.height - heightOffset)
        decorationLayer.position = CGPointMake(self.frame.width/2, self.frame.height/2 - 75)
        decorationLayer.backgroundColor = UIColor.init(white: 0.0, alpha: 0.5).CGColor
//        let shadowPath = UIBezierPath(rect: self.bounds)
//        decorationLayer.shadowPath = shadowPath.CGPath
        decorationLayer.shadowOpacity = 1.0
        decorationLayer.shadowRadius = 1.0
        decorationLayer.shadowOffset = CGSizeMake(0.0, 15.0)
        decorationLayer.masksToBounds = false
        
    }
    
    func insertLayerBelow(Layer layer: CALayer) {
        
        self.layer.insertSublayer(decorationLayer, below: layer)
    }
    
    

}
