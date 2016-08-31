//
//  LWStartViewController.swift
//  LewisWorkout
//
//  Created by brendan kerr on 7/10/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit


extension LWStartViewController : UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        tapPresentAnimation.originFrame = presentationOrigin
        tapPresentAnimation.endFrame = self.view.frame
        return tapPresentAnimation
        
    }
    
//    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
//        //
//        
//    }
}

class LWStartViewController: UIViewController, TableResponseDelegate {
    
    //@IBOutlet var startView: LWStartView!
    @IBOutlet weak var containerView: UIView!
    private let tapPresentAnimation = TapPresentAnimationController()
    private var presentationOrigin = CGRectZero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (self.view as! LWStartView).configure()
        //startView.configure()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print(NSStringFromCGRect(self.view.frame))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        (self.view as! LWStartView).programmedAnimation()
        //startView.programmedAnimation()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("view dissapeared")
    }
    
    func createViewWithCellContents(cell: LWStartTableViewCell, ContentOffset offset: CGFloat) {
        //
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let toVC: LWGameViewController = storyboard.instantiateViewControllerWithIdentifier("LWGameViewController") as! LWGameViewController
        let tempVC: LWTestAnimateViewController = storyboard.instantiateViewControllerWithIdentifier("TestViewController") as! LWTestAnimateViewController
        
        let actualPoint = containerView.convertPoint(cell.frame.origin, toView: self.view)
        print("\(NSStringFromCGPoint(actualPoint))")
        print("\(NSStringFromCGPoint(CGPointMake(containerView.frame.origin.x, containerView.frame.origin.y + cell.frame.origin.y - offset)))")
        //CGRectMake(containerView.frame.origin.x, containerView.frame.origin.y + cell.frame.origin.y - offset, cell.frame.width, cell.frame.height)
        
        
        toVC.view.frame = self.view.frame
        toVC.gameView.stageImageView.image = cell.stageImageView.image
        
        presentationOrigin = toVC.view.frame
        
        tempVC.view.frame = CGRectMake(containerView.frame.origin.x, containerView.frame.origin.y + cell.frame.origin.y - offset, cell.frame.width, cell.frame.height)
        tempVC.backgroundImage.image = cell.stageImageView.image
        tempVC.backgroundImage.clipsToBounds = true
        
        let blackVC = UIViewController()
        blackVC.view.frame = self.view.frame
        blackVC.view.backgroundColor = UIColor.blackColor()
        
        blackVC.view.alpha = 0.0
        tempVC.view.alpha = 0.0
        //toVC.view.alpha = 0.0
        
        self.view.addSubview(blackVC.view)
        self.view.addSubview(tempVC.view)
        //self.view.addSubview(toVC.view)
        
        prepareVCForTransition(FirstViewController: tempVC, SecondViewController: blackVC, ViewControllerToPresent: toVC)
        
    }
    
    
    func prepareVCForTransition(FirstViewController tempVC: UIViewController, SecondViewController blackVC: UIViewController, ViewControllerToPresent presentVC: LWGameViewController) {
        
        UIView.animateWithDuration(1.0, animations: { _ in
            
            blackVC.view.alpha = 1.0
            tempVC.view.alpha = 1.0
            
            }, completion: {(completed: Bool) in
                
                UIView.animateWithDuration(1.0, animations: { _ in
                    
                    tempVC.view.center = CGPointMake(self.view.frame.width/2, self.view.frame.height/2)
                    
                    }, completion: {(completed: Bool) in
                        
                        let cellOffset = tempVC.view.frame.height/2                    
                        presentVC.topHiderView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height/2 - cellOffset)
                        presentVC.bottomHiderView.frame = CGRectMake(0, tempVC.view.frame.origin.y + tempVC.view.frame.height, self.view.frame.width, self.view.frame.height/2 + cellOffset)
                        print("\(NSStringFromCGRect(presentVC.topHiderView.frame)), \(NSStringFromCGRect(presentVC.bottomHiderView.frame)))")
                        
                        presentVC.transitioningDelegate = self
                        self.presentViewController(presentVC, animated: true, completion: nil)
                })

                
        })
    }
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "LWStageTableSegue" {
            print("LWStageTableSegue")
            if let table = segue.destinationViewController as? LWStartTableViewController {
                table.delegate = self
            }
            
            
        }
    }

}




