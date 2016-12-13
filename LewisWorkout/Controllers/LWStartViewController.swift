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
        
//        tapPresentAnimation.originFrame = presentationOrigin
//        tapPresentAnimation.endFrame = self.view.frame
//        return tapPresentAnimation
        
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
    private var presentationOrigin = CGRect.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (self.view as! LWStartView).configure()
        //startView.configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(NSStringFromCGRect(self.view.frame))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (self.view as! LWStartView).programmedAnimation()
        //startView.programmedAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("view dissapeared")
    }
    
    func createViewWithCellContents(cell: LWStartTableViewCell, ContentOffset offset: CGFloat) {
        //
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let toVC: LWGameViewController = storyboard.instantiateViewController(withIdentifier: "LWGameViewController") as! LWGameViewController
        let tempVC: LWTestAnimateViewController = storyboard.instantiateViewController(withIdentifier: "TestViewController") as! LWTestAnimateViewController
        
        let actualPoint = containerView.convert(cell.frame.origin, to: self.view)
        print("\(NSStringFromCGPoint(actualPoint))")
        print("\(NSStringFromCGPoint(CGPoint(x: containerView.frame.origin.x, y: containerView.frame.origin.y + cell.frame.origin.y - offset)))")
        //CGRectMake(containerView.frame.origin.x, containerView.frame.origin.y + cell.frame.origin.y - offset, cell.frame.width, cell.frame.height)
        
        
        toVC.view.frame = self.view.frame
        toVC.gameView.stageImageView.image = cell.stageImageView.image
        
        presentationOrigin = toVC.view.frame
        
        tempVC.view.frame = CGRect(x: containerView.frame.origin.x, y: containerView.frame.origin.y + cell.frame.origin.y - offset, width: cell.frame.width, height: cell.frame.height)
        tempVC.backgroundImage.image = cell.stageImageView.image
        tempVC.backgroundImage.clipsToBounds = true
        
        let blackVC = UIViewController()
        blackVC.view.frame = self.view.frame
        blackVC.view.backgroundColor = UIColor.black
        
        blackVC.view.alpha = 0.0
        tempVC.view.alpha = 0.0
        //toVC.view.alpha = 0.0
        
        self.view.addSubview(blackVC.view)
        self.view.addSubview(tempVC.view)
        //self.view.addSubview(toVC.view)
        
        prepareVCForTransition(FirstViewController: tempVC, SecondViewController: blackVC, ViewControllerToPresent: toVC)
        
    }
    
    
    func prepareVCForTransition(FirstViewController tempVC: UIViewController, SecondViewController blackVC: UIViewController, ViewControllerToPresent presentVC: LWGameViewController) {
        
        UIView.animate(withDuration: 1.0, animations: { _ in
            
            blackVC.view.alpha = 1.0
            tempVC.view.alpha = 1.0
            
            }, completion: {(completed: Bool) in
                
                UIView.animate(withDuration: 1.0, animations: { _ in
                    
                    tempVC.view.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2)
                    
                    }, completion: {(completed: Bool) in
                        
                        let cellOffset = tempVC.view.frame.height/2                    
                        presentVC.topHiderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/2 - cellOffset)
                        presentVC.bottomHiderView.frame = CGRect(x: 0, y: tempVC.view.frame.origin.y + tempVC.view.frame.height, width: self.view.frame.width, height: self.view.frame.height/2 + cellOffset)
                        print("\(NSStringFromCGRect(presentVC.topHiderView.frame)), \(NSStringFromCGRect(presentVC.bottomHiderView.frame)))")
                        
                        presentVC.transitioningDelegate = self
                        self.present(presentVC, animated: true, completion: nil)
                })

                
        })
    }
    
    
    
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "LWStageTableSegue" {
            print("LWStageTableSegue")
            if let table = segue.destination as? LWStartTableViewController {
                table.delegate = self
            }
            
            
        }
    }

}




