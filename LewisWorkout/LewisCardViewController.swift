//
//  LewisCardViewController.swift
//  LewisWorkout
//
//  Created by brendan kerr on 6/1/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class LewisCardViewController: UIViewController {

    
    @IBOutlet var cardFrontView: LewisCardFrontView!
    
    
    required init(coder aDecoder: NSCoder) {
        print("required coder init")
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        print("nibName bundle init")
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        print("normal init")
        self.init(nibName: nil, bundle: nil)
    }
    
    
    override func viewDidLoad() {
        print("card vc viewdidload")
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        print("subviews layed")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
    func newCard(card: LewisCard) {
        
        
        
    }
    
    
    

}
