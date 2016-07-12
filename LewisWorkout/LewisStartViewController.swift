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

    @IBOutlet weak var stageStack: UIStackView!
    @IBOutlet weak var stage1: LewisStageView!
    @IBOutlet weak var stage2: LewisStageView!
    @IBOutlet weak var stage3: LewisStageView!
    @IBOutlet weak var stage4: LewisStageView!
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //startView.backgroundColor = UIColor.darkGrayColor()
        startView.configureLayerShapes()
        startView.configureStartButton()
        startView.configureLabels()
        startView.configureSuits()
    
        
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print(NSStringFromCGRect(self.view.frame))
        
        stage1.stageImage.image = UIImage(named: "menuItem - 1")
        stage2.stageImage.image = UIImage(named: "menuItem - 2")
        stage3.stageImage.image = UIImage(named: "menuItem - 3")
        stage4.stageImage.image = UIImage(named: "menuItem - 4")
        
        stage1.stageLabel.text = "Football"
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
}
