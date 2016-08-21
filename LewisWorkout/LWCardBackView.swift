//
//  LWCardBackView.swift
//  LewisWorkout
//
//  Created by brendan kerr on 6/18/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class LWCardBackView: UIView {
    
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.layer.cornerRadius = LewisGeometricConstants.cornerRadius
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.layer.cornerRadius = LewisGeometricConstants.cornerRadius
    }
    

}
