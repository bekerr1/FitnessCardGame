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
    mutating func layout(Model model: LewisCard, InsideRect rect: CGRect, Sideways side: Bool)
    
}



