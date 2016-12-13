//
//  LewisDetectionStructures.swift
//  LewisWorkout
//
//  Created by brendan kerr on 6/25/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import Foundation
import UIKit

struct DetectDown : DetectionProtocol {
    
    var startingValue: CGFloat
    var allowedChangeInValue: CGFloat
    var transitionDetector: DetectionProtocol
    
    init(WithStartValue start: CGFloat, AllowedChange change: CGFloat, TransitionDetector trans: DetectionProtocol) {
        
        startingValue = start
        allowedChangeInValue = change
        transitionDetector = trans
        
    }
    
    
    func shouldTransitionAfterChange(currentValue: CGFloat) -> Bool {
        
        let change: CGFloat = fabs(startingValue - currentValue)
        if  change >= allowedChangeInValue {
            return true
        }
        return false
    }
    
}


struct DetectUp : DetectionProtocol {
    
    var startingValue: CGFloat
    var allowedChangeInValue: CGFloat
    var transitionDetector: DetectionProtocol
    
    init(WithStartValue start: CGFloat, AllowedChange change: CGFloat, TransitionDetector trans: DetectionProtocol) {
        
        startingValue = start
        allowedChangeInValue = change
        transitionDetector = trans
        
    }
    
    
    func shouldTransitionAfterChange(currentValue: CGFloat) -> Bool {
        
        let change: CGFloat = fabs(startingValue - currentValue)
        if  change >= allowedChangeInValue {
            return true
        }
        return false
    }
}