//
//  LewisGameViewController.swift
//  LewisWorkout
//
//  Created by brendan kerr on 5/29/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class LewisGameViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var pushupCountLabel: UILabel!
    @IBOutlet weak var currentCardLabel: UILabel!
    @IBOutlet weak var cardsCompletedLabel: UILabel!
    
    @IBOutlet weak var currentCardContainer: UIView!
    @IBOutlet weak var deckViewContainer: UIView!
    
    @IBOutlet weak var deckPlaceholderView: LewisDeckPlaceholderView!
    private var deckVC: LewisDeckViewController!
    private var currentCardVC: LewisCardViewController!
    
    private var tap: Bool = false
    
    //MARK: Initialize
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let deckTapDesture = UITapGestureRecognizer(target: self, action: #selector(deckTap))
        let deckGestures = [deckTapDesture]
        deckPlaceholderView.gestureRecognizers = deckGestures
        deckPlaceholderView.referenceRect = deckViewContainer.frame
        //deckPlaceholderView.createStackEffect()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        deckPlaceholderView.createStackEffect()
    }
    
    override func viewDidLayoutSubviews() {
        print("subviews layed")
        
        if self.tap {
            animationStart()
            tap = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Actions
    
    func deckTap() {
        print("DeckTapped " + #function)
        
        self.view.bringSubviewToFront(self.deckViewContainer)
        tap = true
    }
    
    
    func animationStart() {
        
        let originalTransform = self.deckViewContainer.transform
        let originalFrame = self.deckViewContainer.frame
        
        deckVC.deckTapTransitionTo()

        UIView.animateWithDuration(1.0, animations: { () -> () in
            
            self.deckViewContainer.frame.size = CGSizeMake(self.currentCardContainer.frame.size.height, self.currentCardContainer.frame.size.width)
            self.deckViewContainer.center = self.currentCardContainer.center
            self.deckViewContainer.transform = CGAffineTransformRotate(self.deckViewContainer.transform, CGFloat(M_PI * 1.5))
            
            },
            completion: {(complete: Bool) -> () in
                print("animation 1 completed.")
                
        })
        
        
        UIView.animateWithDuration(0.6, delay: 0.4, options: .Autoreverse, animations: {() -> () in
            
            self.deckViewContainer.transform = CGAffineTransformScale(self.deckViewContainer.transform, 1.3, 1.3);
            
            }, completion: {(complete: Bool) -> () in
                print("Transform animation completed")
                
                self.setCardVCViewToAnimated()
                self.resetViewsForNextAnimation(originalTransform: originalTransform, originalFrame: originalFrame)
                
        })

    }
    
    
    func setCardVCViewToAnimated() {
        //Get the deckVC's current deck model and set it to the cardVC's deck model
        currentCardVC.setViewToNewCard(deckVC.cardFrontView.currentCard)    
    }
    
    
    func resetViewsForNextAnimation(originalTransform trans: CGAffineTransform, originalFrame frame: CGRect) {
        
        self.view.bringSubviewToFront(self.deckPlaceholderView)
        self.deckVC.resetTransitionViews()
        self.deckViewContainer.transform = trans
        self.deckViewContainer.frame = frame
    }
    
    
    //MARK: Prepare for Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "deckSegue" {
            print("deck segue")
            deckVC = segue.destinationViewController as? LewisDeckViewController
        } else if segue.identifier == "cardSegue" {
            print("card segue")
            currentCardVC = segue.destinationViewController as? LewisCardViewController
        }
    }

}


//Tried to add view programatically but couldnt get it to follow constraits i wanted
//tried to add constraits and there was a conflict
//        deckPlaceholderView = UIView(frame: deckViewContainer.frame)
//        deckPlaceholderView.backgroundColor = UIColor.yellowColor()
//        deckPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
//        self.view.addSubview(deckPlaceholderView)
//        self.view.bringSubviewToFront(deckViewContainer)'







