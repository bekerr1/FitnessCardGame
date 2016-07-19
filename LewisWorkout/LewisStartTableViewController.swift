//
//  LewisStartTableViewController.swift
//  LewisWorkout
//
//  Created by JOSEPH KERR on 7/12/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit


class LewisStartTableViewCell: UITableViewCell {
    @IBOutlet weak var stageLabel: UILabel!
    @IBOutlet weak var stageImageView: UIImageView!
}

protocol TableResponseDelegate {
    
    func createViewWithCellContents(cell: LewisStartTableViewCell, ContentOffset offset: CGFloat)
}


class LewisStartTableViewController: UITableViewController {

    
    var delegate: TableResponseDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backView = UIView()
        backView.backgroundColor = UIColor.blackColor()
        self.tableView.backgroundView = backView
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Table view delegate

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if let stageCell = cell as? LewisStartTableViewCell {
            if indexPath.row == 0 {
                stageCell.stageImageView.image = UIImage(named: "menuItem - 1")
                stageCell.stageLabel.text = "Football"
            } else if indexPath.row == 1 {
                stageCell.stageImageView.image = UIImage(named: "menuItem - 2")
                stageCell.stageLabel.text = "Basketball"
                
            } else if indexPath.row == 2 {
                stageCell.stageImageView.image = UIImage(named: "menuItem - 3")
                stageCell.stageLabel.text = "Soccer"
                
            }else if indexPath.row == 3 {
                stageCell.stageImageView.image = UIImage(named: "menuItem - 4")
                stageCell.stageLabel.text = "Hockey"
                
            }
        }
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let supplView = UIView()
        supplView.backgroundColor = UIColor.blackColor()
        return supplView
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let supplView = UIView()
        supplView.backgroundColor = UIColor.blackColor()
        return supplView
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LewisCell", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //
        let cellSelected: LewisStartTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! LewisStartTableViewCell
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: false)
        
        delegate?.createViewWithCellContents(cellSelected, ContentOffset: self.tableView.contentOffset.y)
        
    }
   
}
