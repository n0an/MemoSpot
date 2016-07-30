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


        
        print("locations = \(locations)")
        
        
    }

    
}
