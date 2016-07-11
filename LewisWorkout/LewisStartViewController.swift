//
//  LewisStartViewController.swift
//  LewisWorkout
//
//  Created by brendan kerr on 7/10/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class LewisStartViewController: UIViewController {
    
    
    @IBOutlet var startView: LewisStartView!

    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print(NSStringFromCGRect(self.view.frame))
        
        //startView.backgroundColor = UIColor.darkGrayColor()
        startView.configureLayerShapes()
        startView.configureStartButton()
        startView.configureLabels()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        startView.animateLabelsToPosition()
        startView.animateButtonToPosition()
    }
}
