//
//  MapViewController.swift
//  MyLocations
//
//  Created by Anton Novoselov on 18/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - PROPERTIES

    var managedObjectContext: NSManagedObjectContext! {
        
        // !!!IMPORTANT!!!
        // Listening for Notification - changing in CoreData
        
        didSet {
            
            NSNotificationCenter.defaultCenter().addObserverForName(
                NSManagedObjectContextObjectsDidChangeNotification,
                object: managedObjectContext,
                queue: NSOperationQueue.mainQueue()) { notification in
                    
                    // TODO: make the reloading of the locations more efficient by not re-fetching the entire list of Location objects, but by only inserting or deleting those that have changed
                    if let dictionary = notification.userInfo {
                        print(dictionary["inserted"])
                        print(dictionary["deleted"])
                        print(dictionary["updated"])
                    }
                    
                    if self.isViewLoaded() { // CHECKING IF VIEW LOADED TO AVOID CRASH WHEN RECEIVE NOTIFICATION
                        self.updateLocations()
                    }
                    
            }
        }
        
    }
    
    var locations = [Location]()

    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLocations()
        
        if !locations.isEmpty {
            showLocations()
        }

    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - HELPER METHODS
    
    func updateLocations() {
        
        mapView.removeAnnotations(locations)
        
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
        
        let fetchRequest = NSFetchRequest()
        
        fetchRequest.entity = entity
        
        locations = try! managedObjectContext.executeFetchRequest(fetchRequest) as! [Location]
        
        mapView.addAnnotations(locations)
    
    }
    
    
    func regionForAnnotations(annotations: [MKAnnotation]) -> MKCoordinateRegion {
        
        var region: MKCoordinateRegion
        
        switch annotations.count {
        
        case 0:
            region = MKCoordinateRegionMakeWithDistance( mapView.userLocation.coordinate, 1000, 1000)
            
        case 1:
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
            
        default:
            
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            
            for annotation in annotations {
                
                topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
                
                topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
                
                bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)
                
                bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2D(
                latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2,
                longitude: topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
            
            let extraSpace = 1.1
            
            let span = MKCoordinateSpan(
                latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace,
                longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)
            
            region = MKCoordinateRegion(center: center, span: span)
        
        }
        
        return mapView.regionThatFits(region)
        
    }
    
    
    
    
    
    
    // MARK: - ACTIONS

    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    @IBAction func showLocations() {
        
        let region = regionForAnnotations(locations)
        
        mapView.setRegion(region, animated: true)
        
    }
    
    func showLocationDetails(sender: UIButton) {
        
        performSegueWithIdentifier("EditLocation", sender: sender)
        
    }
    
    
    
    
    // MARK: - NAVIGATION
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "EditLocation" {
            
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let controller = navigationController.topViewController as! LocationDetailsViewController
            
            controller.managedObjectContext = managedObjectContext
            
            let button = sender as! UIButton
            
            let location = locations[button.tag]
            
            controller.locationToEdit = location
        }
    
    }
    

}



// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is Location else { return nil }
        
        let identifier = "Location"
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as! MKPinAnnotationView!
        
        if annotationView == nil { // Create annotationView, if there's no annotationView already
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            annotationView.enabled = true
            annotationView.canShowCallout = true
            annotationView.animatesDrop = false
            annotationView.pinTintColor = UIColor(red: 0.32, green: 0.82, blue: 0.4, alpha: 1)
            
            annotationView.tintColor = UIColor(white: 0.0, alpha: 0.5)
            
            
            let rightButton = UIButton(type: .DetailDisclosure)
            rightButton.addTarget(self, action: #selector(MapViewController.showLocationDetails(_:)), forControlEvents: .TouchUpInside)
            
            annotationView.rightCalloutAccessoryView = rightButton
            
        } else { // Reuse annotationView
            
            annotationView.annotation = annotation
            
        }
        
        let button = annotationView.rightCalloutAccessoryView as! UIButton
        
        if let index = locations.indexOf(annotation as! Location) {
            button.tag = index
        }
        
        return annotationView
        

    }
    
    
}


// !!!IMPORTANT!!!
// SOLVING HIDDEN STATUS BAR ISSUE

extension MapViewController: UINavigationBarDelegate {
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
}













