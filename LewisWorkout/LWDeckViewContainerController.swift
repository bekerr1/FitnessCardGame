//
//  LWDeckViewContainerController.swift
//  LewisWorkout
//
//  Created by brendan kerr on 8/22/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class LWDeckViewContainerController: UIViewController {
    

    
    func displayContentController(ViewController content: UIViewController) {
        addChildViewController(content)
        content.view.frame = view.frame
        view.addSubview(content.view)
        content.didMoveToParentViewController(self)
        
        
    }

}
