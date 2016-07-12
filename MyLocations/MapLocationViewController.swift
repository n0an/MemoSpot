//
//  MapLocationViewController.swift
//  MyLocations
//
//  Created by Anton Novoselov on 12/07/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import MapKit

class MapLocationViewController: UIViewController {

    
    // MARK: - OUTLETS
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - PROPERTIES
    
    var weather: WeeklyWeather!
    
    var isShadowShowing = false
    
    var locationToEdit: Location!
    var locations = [Location]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateLocations()

        if !locations.isEmpty {
            showLocations()
        }

    }

    
    // MARK: - HELPER METHODS
    
    func updateLocations() {
        
        mapView.removeAnnotations(locations)
        
        locations.append(locationToEdit)
        
        mapView.addAnnotations(locations)
        
    }
    
    func showLocations() {
        
        let region = regionForAnnotations(locations)
        
        mapView.setRegion(region, animated: true)
        
    }
    
    func showLocationDetails(sender: UIButton) {
        
        
        
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
            
            let extraSpace = 1.5
            
            let span = MKCoordinateSpan(
                latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace,
                longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)
            
            region = MKCoordinateRegion(center: center, span: span)
            
        }
        
        return mapView.regionThatFits(region)
        
    }
    
    
    
    // MARK: - ACTIONS
    
    @IBAction func showShadows(sender: UIBarButtonItem) {
        
        print("sunriseTime = \(timeStringFromUnixtime(weather.sunriseTime))")
        print("sunsetTime = \(timeStringFromUnixtime(weather.sunsetTime))")

        
        if isShadowShowing {
            if let viewToRemove = mapView.viewWithTag(111) {
                viewToRemove.removeFromSuperview()
            }
            
            isShadowShowing = false
            
        } else {
            
            let shadowRect = CGRect(x: CGRectGetMidX(mapView.bounds), y: CGRectGetMidY(mapView.bounds), width: 100, height: 10)
            
            let shadowView = UIView(frame: shadowRect)
            
            shadowView.backgroundColor = UIColor.grayColor()
            
            if let viewToRemove = mapView.viewWithTag(111) {
                viewToRemove.removeFromSuperview()
            }
            
            mapView.addSubview(shadowView)
            shadowView.tag = 111
            
            isShadowShowing = true
        }
        
        
        
    }
    
    
    

}










// MARK: - MKMapViewDelegate

extension MapLocationViewController: MKMapViewDelegate {
    
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
            rightButton.addTarget(self, action: #selector(MapLocationViewController.showLocationDetails(_:)), forControlEvents: .TouchUpInside)
            
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











