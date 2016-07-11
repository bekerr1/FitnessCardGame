//
//  LewisStageTableView.swift
//  LewisWorkout
//
//  Created by brendan kerr on 7/10/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class LewisStageTableView: UITableView, UITableViewDelegate {
    
    
    //var differentStages: [UIImage] = Array()
    var differentStages = Dictionary<String, UIImage>()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        self.delegate = self
    }
    
    
    
    

}
