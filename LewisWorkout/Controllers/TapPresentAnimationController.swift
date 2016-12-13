//
//  TapPresentAnimationController.swift
//  LewisWorkout
//
//  Created by brendan kerr on 7/18/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class TapPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    
    var originFrame = CGRect.zero
    var endFrame = CGRect.zero
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2.0
    }
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //
        
    
        let containerView = transitionContext.containerView
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? LWGameViewController else {
            return
        }
        
        
        toVC.view.frame = endFrame
        containerView.addSubview(toVC.view)
        //let views = containerView.subviews
        print("\(NSStringFromCGRect(toVC.view.frame))")
        
        let topAnimateUp = CGPoint(x: 0, y: -toVC.topHiderView.frame.height)
        let bottomAnimateDown = CGPoint(x: 0, y: toVC.view.frame.height)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            print("animate center")
            
            toVC.topHiderView.frame.origin = topAnimateUp
            toVC.bottomHiderView.frame.origin = bottomAnimateDown
            
            }, completion: {(success: Bool) in
                print("contextComplete")
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
        
        
        

    }
    

}

//if success {
//    
//    UIView.animateWithDuration(2.0, animations: {_ in
//        print("animate frame")
//        
//        
//        
//        }, completion: nil)
//    
//}


//        UIView.animateKeyframesWithDuration(transitionDuration(transitionContext), delay: 0.0, options: UIViewKeyframeAnimationOptions.CalculationModeLinear, animations: {
//
//
//            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 1/2, animations: {
//                toVC.view.center = CGPointMake(finalFrame.size.width/2, finalFrame.size.height/2)
//                //containerView.center = CGPointMake(finalFrame.size.width/2, finalFrame.size.height/2)
//            })
//
//            UIView.addKeyframeWithRelativeStartTime(1/2, relativeDuration: 1/2, animations: {
//                toVC.view.bounds = finalFrame
//            })
//
//
//            }, completion: nil)
