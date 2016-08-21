//
//  TapPresentAnimationController.swift
//  LewisWorkout
//
//  Created by brendan kerr on 7/18/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class TapPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    
    var originFrame = CGRectZero
    var endFrame = CGRectZero
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 2.0
    }
    
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        //
        
    
        guard let containerView = transitionContext.containerView(),
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? LWGameViewController else {
            return
        }
        
        
        toVC.view.frame = endFrame
        containerView.addSubview(toVC.view)
        //let views = containerView.subviews
        print("\(NSStringFromCGRect(toVC.view.frame))")
        
        let topAnimateUp = CGPointMake(0, -toVC.topHiderView.frame.height)
        let bottomAnimateDown = CGPointMake(0, toVC.view.frame.height)
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
            print("animate center")
            
            toVC.topHiderView.frame.origin = topAnimateUp
            toVC.bottomHiderView.frame.origin = bottomAnimateDown
            
            }, completion: {(success: Bool) in
                print("contextComplete")
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
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
