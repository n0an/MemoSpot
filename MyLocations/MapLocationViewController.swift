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
    @IBOutlet weak var timeButton: UIButton!
    
    @IBOutlet weak var timeSlider: UISlider!
    
    @IBOutlet weak var dateButton: UIButton!
    
    
    
    // MARK: - PROPERTIES
    
    var weather: WeeklyWeather!
    
    var isShadowShowing = false
    
    var locationToEdit: Location!
    var locations = [Location]()

    var currentAngle: CGFloat = 0
    var shadowWidth: CGFloat!
    
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
    
    
    @IBAction func actionTimeSliderValueChanged(sender: UISlider) {
        
        let selectedTime = Int(sender.value * 24)
        
//        print("selectedTime = \(selectedTime)")
        
        
        let sunriseTimeInSeconds = NSTimeInterval(weather.sunriseTime)
        let sunsetTimeInSeconds = NSTimeInterval(weather.sunsetTime)
        
        let sunriseDate = NSDate(timeIntervalSince1970: sunriseTimeInSeconds)
        let sunsetDate = NSDate(timeIntervalSince1970: sunsetTimeInSeconds)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH"
        
        let sunriseTime = Int(dateFormatter.stringFromDate(sunriseDate))
        let sunsetTime = Int(dateFormatter.stringFromDate(sunsetDate))
        let dayLightSpan = sunsetTime! - sunriseTime!
        
        let deltaAngel = CGFloat(M_PI) / CGFloat(dayLightSpan)
        let deltaWidth = shadowWidth / CGFloat(dayLightSpan)
        
        let shadowView = mapView.viewWithTag(111)
        
        
        if selectedTime >= sunriseTime && selectedTime <= sunsetTime {
            
            shadowView?.hidden = false
            
            currentAngle = CGFloat(selectedTime - sunriseTime!) * deltaAngel
            
            let doubleDayLightSpan = Double(dayLightSpan)
            
            let currentWidth = pow((Double(selectedTime - sunriseTime!) - doubleDayLightSpan/2), 2)*3 + 30
            
            print("currentWidth = \(currentWidth)")
            
            
            
//            let rotationTransform = CGAffineTransformMakeRotation(currentAngle)
//            let scaleTransform = CGAffineTransformMakeScale(deltaWidth, 1)
            
            shadowView?.transform = CGAffineTransformMakeRotation(currentAngle)
//            shadowView?.transform = CGAffineTransformConcat(rotationTransform, scaleTransform)
            
            shadowView?.bounds.size.width = CGFloat(currentWidth)
            
            
            
        } else {
            
            shadowView?.hidden = true

        }


        
    }
    
    @IBAction func showShadows(sender: UIBarButtonItem) {
        
//        print("sunriseTime = \(timeStringFromUnixtime(weather.sunriseTime))")
//        print("sunsetTime = \(timeStringFromUnixtime(weather.sunsetTime))")
        
        
        
        
        let sunriseTimeInSeconds = NSTimeInterval(weather.sunriseTime)
        let sunsetTimeInSeconds = NSTimeInterval(weather.sunsetTime)

        let weatherDate = NSDate(timeIntervalSince1970: sunriseTimeInSeconds)
        
        let currentDate = NSDate()
        let interval = currentDate.timeIntervalSinceDate(weatherDate)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        
        print("currentDate = \(dateFormatter.stringFromDate(currentDate))")
        print("weatherDate = \(dateFormatter.stringFromDate(weatherDate))")
        print("interval = \(interval)")

        
        
        if isShadowShowing {
            if let viewToRemove = mapView.viewWithTag(111) {
                viewToRemove.removeFromSuperview()
            }
            
            isShadowShowing = false
            
        } else {
            
            let minMetric = min(view.bounds.size.width, view.bounds.size.height)
            
            shadowWidth = minMetric * 0.4
            
            let shadowRect = CGRect(x: CGRectGetMidX(mapView.bounds) - shadowWidth/2, y: CGRectGetMidY(mapView.bounds), width: shadowWidth, height: 10)
            
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













