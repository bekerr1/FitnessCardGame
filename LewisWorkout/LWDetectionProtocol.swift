//
//  LewisDetectionProtocol.swift
//  LewisWorkout
//
//  Created by brendan kerr on 6/25/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import Foundation
import UIKit

protocol DetectionProtocol {
    
    
    var startingValue: CGFloat {get set}
    var allowedChangeInValue: CGFloat {get set}
    var transitionDetector: DetectionProtocol {get set}
    
    func shouldTransitionAfterChange(currentValue: CGFloat) -> Bool
}