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
    @IBOutlet weak var blurView: UIVisualEffectView!

    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //startView.backgroundColor = UIColor.darkGrayColor()
        
        startView.configure()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print(NSStringFromCGRect(self.view.frame))
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        startView.programmedAnimation()
        
//        startView.animateLabelsToPosition()
//        startView.animateButtonToPosition()
//        
//        let delaySeconds1 = 1.0
//        let delayTime1 = dispatch_time(DISPATCH_TIME_NOW, Int64(delaySeconds1 * Double(NSEC_PER_SEC)))
//        dispatch_after(delayTime1, dispatch_get_main_queue()) {
//            self.startView.animateSuitsToPosition()
//        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "LWStageTableSegue" {
            print("LWStageTableSegue")
            
        }
    }

}
