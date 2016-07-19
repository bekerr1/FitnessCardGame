//
//  LewisStageView.swift
//  LewisWorkout
//
//  Created by brendan kerr on 7/12/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class LewisStageView: UIView {
    
    
    var stageImage: UIImageView!
    var stageLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.clipsToBounds = true
        
        print(NSStringFromCGRect(self.frame))
        
        stageImage = UIImageView(frame: self.frame)
        stageImage.translatesAutoresizingMaskIntoConstraints = false
        stageImage.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        stageImage.contentMode = .ScaleAspectFill
        
        stageLabel = UILabel(frame: self.frame)
        
        self.addSubview(stageImage)
        self.addSubview(stageLabel)
    }
    

    
    
}




extension LewisStageView {
    func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> LewisStageView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(self, options: nil)[0] as? LewisStageView
    }
}
