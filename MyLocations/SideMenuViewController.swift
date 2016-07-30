//
//  SideMenuViewController.swift
//  MyLocations
//
//  Created by Anton Novoselov on 30/07/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreData

class SideMenuViewController: UITableViewController {
    
    // MARK: - PROPERTIES
    
    
    var managedObjectContext: NSManagedObjectContext!
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)

        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .White

        
    }

    // MARK: - NAVIGATION

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowWeathers" {
            
            let destinationNavVC = segue.destinationViewController as! UINavigationController
            
            let destinationVC = destinationNavVC.topViewController as! LocationsWeatherViewController
            
            destinationVC.managedObjectContext = managedObjectContext
            
            
        }
        
    }
    
    
    // MARK: - UITableViewDelegate

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        
        if let textLabel = cell.textLabel {
            
            textLabel.textColor = UIColor.whiteColor()
            
            textLabel.highlightedTextColor = textLabel.textColor
            
        }
        
        let selectionView = UIView(frame: CGRect.zero)
        
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        
        cell.selectedBackgroundView = selectionView

        
    }

}
