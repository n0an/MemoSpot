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

        
    }

    // MARK: - NAVIGATION

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowWeathers" {
            
            let destinationNavVC = segue.destinationViewController as! UINavigationController
            
            let destinationVC = destinationNavVC.topViewController as! LocationsWeatherViewController
            
            destinationVC.managedObjectContext = managedObjectContext
            
        }
        
        
    }
   

}
