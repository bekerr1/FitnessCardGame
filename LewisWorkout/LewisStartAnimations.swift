//
//  LewisStartAnimations.swift
//  LewisWorkout
//
//  Created by brendan kerr on 7/13/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//


import UIKit


protocol Animatable {
    
    func animateToPosition(position: CGPoint, _ interval: NSTimeInterval, _ delay: NSTimeInterval, _ options: UIViewAnimationOptions, _ completion: ((Bool) -> Void)?)
    func animateWithSpringToPosition(position: CGPoint, _ interval: NSTimeInterval, _ delay: NSTimeInterval, _ options: UIViewAnimationOptions, _ completion: ((Bool) -> Void)?)
}


extension Animatable {
    
    func animateToPosition(position: CGPoint, _ interval: NSTimeInterval, _ delay: NSTimeInterval, _ options: UIViewAnimationOptions, _ completion: ((Bool) -> Void)?) {
        
        UIView.animateWithDuration(interval, delay: delay, options: options, animations: <#T##() -> Void#>, completion: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>)
    }
}


struct Animator {
    
    
    
}