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
    
    // MARK: - PROPERTIES
    
    var managedObjectContext: NSManagedObjectContext!
    
    lazy var fetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in 
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        let entity = NSEntityDescription.entity(forEntityName: "Location", in: self.managedObjectContext)
        
        fetchRequest.entity = entity
        
        let sortDescriptor1 = NSSortDescriptor(key: "category", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "date", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: "category",
            cacheName: "Locations")
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        performFetch()
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        tableView.backgroundColor = UIColor.black
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .white
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let name = "MemoSpot~\(title)"
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: name)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
        
    }
    
    
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    
    // MARK: - HELPER METHODS
    
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }

    
    
    // MARK: - NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "EditLocation" {
            
            let navigationController = segue.destination as! UINavigationController
            
            let controller = navigationController.topViewController as! LocationDetailsViewController
            
            controller.managedObjectContext = managedObjectContext
            
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                
                let location = fetchedResultsController.object(at: indexPath) as! Location

                controller.locationToEdit = location
            }
        }
        
        
        if segue.identifier == "ShowMenu" {
            
            let navigationController = segue.destination as! UINavigationController
            
            let controller = navigationController.topViewController as! SideMenuViewController
            
            controller.managedObjectContext = managedObjectContext
            
        }
    }
    

    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        
        return sectionInfo.name.uppercased()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = fetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        
        let location = fetchedResultsController.object(at: indexPath) as! Location
        
        cell.configureForLocation(location)
        
        return cell
        
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let labelRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 14, width: 300, height: 14)
        
        let label = UILabel(frame: labelRect)
        
        label.font = UIFont.boldSystemFont(ofSize: 11)
        
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        label.textColor = UIColor(white: 1.0, alpha: 0.4)
        label.backgroundColor = UIColor.clear
        
        let separatorRect = CGRect(x: 15,
                                   y: tableView.sectionHeaderHeight - 0.5,
                                   width: tableView.bounds.size.width - 15,
                                   height: 0.5)
        
        let separator = UIView(frame: separatorRect)
        
        separator.backgroundColor = tableView.separatorColor
        
        let viewRect = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.sectionHeaderHeight)
        
        let view = UIView(frame: viewRect)
        
        view.backgroundColor = UIColor(white: 0, alpha: 0.85)
        
        view.addSubview(label)
        
        view.addSubview(separator)
        
        return view
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let location = fetchedResultsController.object(at: indexPath) as! Location
            
            location.removePhotoFile()
            managedObjectContext.delete(location)
            
            do {
                try managedObjectContext.save()
                
            } catch {
                fatalCoreDataError(error)
            }
        }
    }
    
    
}



// MARK: - NSFetchedResultsControllerDelegate

extension LocationsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        
        
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        case .delete:
            
            tableView.deleteRows(at: [indexPath!], with:.fade)
            
        case .update:
            
            if let cell = tableView.cellForRow(at: indexPath!) as? LocationCell {
                
                let location = controller.object(at: indexPath!) as! Location
                cell.configureForLocation(location)
            }
            
        case .move:
            
            tableView.deleteRows(at: [indexPath!], with: .fade)
            
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
            
        case .insert:
            
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            
        case .delete:
            
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            
        case .update: break
            
            
        case .move: break
            
        }
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        
        
        tableView.endUpdates()
    }
}









