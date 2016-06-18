//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Anton Novoselov on 18/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
    
    // MARK: - OUTLETS
    
    // MARK: - ATTRIBUTES
    
    var managedObjectContext: NSManagedObjectContext!
    
    var locations = [Location]()
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
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

    // MARK: - UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return locations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath)
        
        let location = locations[indexPath.row]
        
        
        let descriptionLabel = cell.viewWithTag(100) as! UILabel
        descriptionLabel.text = location.locationDescription
        
        let addressLabel = cell.viewWithTag(101) as! UILabel
        
        if let placemark = location.placemark {
            
            var text = ""
            
            if let s = placemark.subThoroughfare {
                text += s + " "
            }
            
            if let s = placemark.thoroughfare {
                text += s + " "
            }
            
            if let s = placemark.locality {
                text += s
            }
            
            addressLabel.text = text
            
        } else {
            addressLabel.text = ""
        }
        
        
        
        return cell
        
    }

  

}
