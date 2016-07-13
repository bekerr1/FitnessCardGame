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
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "LWStageTableSegue" {
            print("LWStageTableSegue")
            
        }
    }

}
