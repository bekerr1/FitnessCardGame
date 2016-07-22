//
//  LWCalibrateControlViewController.swift
//  LewisWorkout
//
//  Created by brendan kerr on 7/22/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class LWCalibrateControlViewController: UIViewController {
    
    
    private let calibrateSlider: LWAnimatedSlider = LWAnimatedSlider(frame: CGRectZero)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func configCalibrator() {
        
        self.view.backgroundColor = UIColor.clearColor()
        
        calibrateSlider.frame = CGRect(x: 0, y: 0,
                                      width: view.bounds.width, height: view.bounds.height)

        //calibrateSlider.frame = CGRect(x: 0, y: 0,
        //                               width: 150, height: 61.0)
        calibrateSlider.backgroundColor = UIColor(white: 0.1, alpha: 0.9)
        calibrateSlider.layer.cornerRadius = 10.0
        calibrateSlider.configLayerFrames()
        calibrateSlider.layer.borderColor = UIColor.blackColor().CGColor
        calibrateSlider.layer.borderWidth = 1.0
        //calibrateSlider.horizontal = false
        //calibrateSlider.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(calibrateSlider)
    }

}
