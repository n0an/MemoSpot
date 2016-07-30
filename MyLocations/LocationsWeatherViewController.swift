//
//  LocationsWeatherViewController.swift
//  MyLocations
//
//  Created by Anton Novoselov on 30/07/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreData

class LocationsWeatherViewController: UITableViewController {
    
    // MARK: - PROPERTIES
    
    var locations: [Location]!
    
    var managedObjectContext: NSManagedObjectContext!
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.blackColor()
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .White

        
        let fetchRequest = NSFetchRequest()
        
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
        
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let foundObjects = try managedObjectContext.executeFetchRequest(fetchRequest)
            
            locations = foundObjects as! [Location]
            
        } catch {
            fatalCoreDataError(error)
        }
        
    }

    
    
    // MARK: - ACTIONS

    @IBAction func actionMenuPressed(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - NAVIGATION
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowWeather" {
            
            
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                
                let location = locations[indexPath.row]
                
                let controller = segue.destinationViewController as! WeatherViewController
                
                controller.locationToEdit = location
            }
            
        }
        
    }

    
    
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return locations.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as! LocationCell
        
        let location = locations[indexPath.row]
        
        
        cell.configureForLocation(location)
        
        return cell
        
    }
    
    
    // MARK: - UITableViewDelegate
    
    
    
}






