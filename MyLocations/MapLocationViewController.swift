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
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var timeSlider: UISlider!
    
    @IBOutlet weak var dateButton: UIButton!
    
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var weatherImageViewContainer: UIView!
    
    // MARK: - PROPERTIES
    
    var weather: WeeklyWeather!
    
    var isWeatherAvailable = false
    
    var isShadowShowing = false
    
    var locationToEdit: Location!
    var locations = [Location]()

    var currentAngle: CGFloat = 0
    var shadowWidth: CGFloat!
    
    var shadowView: UIImageView!
    
    
    var sunriseTime: Int!
    var sunsetTime: Int!
    
    var dayLightSpan: Int!
    
    var deltaAngel: CGFloat!
    
    var weatherDate = NSDate()

    let calend = ANConfigurator.sharedConfigurator.calendar
    
    var components: NSDateComponents!
    
    var diffComponents: NSDateComponents!
    
    
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCurrentWeatherData()

        updateLocations()

        if !locations.isEmpty {
            showLocations()
        }
        
        components = calend.components([.Month, .Day], fromDate: weatherDate)
        
        refreshDateButton()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
     
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        
        initShadowView()
        
        
        

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

    
    
    func calculateTimeStamps() {
        
        let sunriseTimeInSeconds = NSTimeInterval(weather.sunriseTime)
        let sunsetTimeInSeconds = NSTimeInterval(weather.sunsetTime)
        
        let sunriseDate = NSDate(timeIntervalSince1970: sunriseTimeInSeconds)
        let sunsetDate = NSDate(timeIntervalSince1970: sunsetTimeInSeconds)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH"
        
        sunriseTime = Int(dateFormatter.stringFromDate(sunriseDate))
        sunsetTime = Int(dateFormatter.stringFromDate(sunsetDate))
        
        dayLightSpan = sunsetTime! - sunriseTime!
        
        deltaAngel = CGFloat(M_PI) / CGFloat(dayLightSpan)
        
        
    }
    
    func initShadowView() {
        
        let shadowImageView = UIImageView(image: UIImage(named: "shadowArrow"))
        shadowImageView.frame.origin = CGPoint(x: CGRectGetMidX(view.bounds), y: CGRectGetMidY(view.bounds))
        
        view.addSubview(shadowImageView)
        
        shadowView = shadowImageView
        
        shadowView.hidden = true
        
    }

    func refreshShadow() {
        
        let selectedTime = Int(timeSlider.value * 24)
        
        if selectedTime >= sunriseTime && selectedTime <= sunsetTime {
            
            shadowView?.hidden = false
            
            currentAngle = CGFloat(selectedTime - sunriseTime!) * deltaAngel
            
            let doubleDayLightSpan = Double(dayLightSpan)
            
            let currentWidth = pow((Double(selectedTime - sunriseTime!) - doubleDayLightSpan/2), 2)*3 + 30
            
            shadowView?.transform = CGAffineTransformMakeRotation(currentAngle)
            
            shadowView?.bounds.size.width = CGFloat(currentWidth)
            
        } else {
            
            shadowView?.hidden = true
            
        }

    }
    
    
    func refreshDateButton() {
        
        let dateString = ANConfigurator.sharedConfigurator.dateFormatter.stringFromDate(weatherDate)
        
        dateButton.setTitle(dateString, forState: .Normal)
    }
    
    
    
    
    // MARK: - WEATHER METHODS
    
    func getCurrentWeatherData() -> Void {
        
        let userLocation = "\(locationToEdit.coordinate.latitude),\(locationToEdit.coordinate.longitude)"
        
        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        let forecastURL = NSURL(string: "\(userLocation)", relativeToURL:baseURL)
        
        
        let sharedSession = NSURLSession.sharedSession()
        
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(forecastURL!, completionHandler: { (location: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if (error == nil) {
                
                let dataObject = NSData(contentsOfURL: location!)
                let weatherDictionary: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(dataObject!, options: [])) as! NSDictionary
                
                let currentWeather = CurrentWeather(weatherDictionary: weatherDictionary)
                let weeklyWeather = WeeklyWeather(weatherDictionary: weatherDictionary)
                
                self.weather = weeklyWeather
                
                print(weatherDictionary)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    print("temperature = \(Fahrenheit2Celsius(currentWeather.temperature))")
                    print("humidity = \(currentWeather.humidity)")
                    
                    //7 day out look
                    
                    print("tempDayOne = \(Fahrenheit2Celsius(weeklyWeather.dayOneTemperatureMin))°/ \(Fahrenheit2Celsius(weeklyWeather.dayOneTemperatureMax))°")
                    
                    print("tempDayTwo = \(Fahrenheit2Celsius(weeklyWeather.dayTwoTemperatureMin))°/ \(Fahrenheit2Celsius(weeklyWeather.dayTwoTemperatureMax))°")
                    
                    print("dayOneTime = \(weeklyWeather.dayOneTime!)")
                    print("dayTwoTime = \(weeklyWeather.dayTwoTime!)")
                    print("dayThreeTime = \(weeklyWeather.dayThreeTime!)")
                    
                    self.isWeatherAvailable = true
                    self.calculateTimeStamps()
                    self.weatherImageView.image = self.weather.dayZeroIcon

                })
                
                
                
            } else {
                
                
            }
            
        })
        
        downloadTask.resume()
        
    }
    
    
    
    // MARK: - ACTIONS
    
    @IBAction func actionTimeSliderValueChanged(sender: UISlider) {
        
        timeLabel.text = "\(Int(sender.value * 24)):00"
        
        guard isShadowShowing else {return}
        
        refreshShadow()
        
    }
    
    
    
    @IBAction func showShadows(sender: UIBarButtonItem) {
        
        if isShadowShowing {
            shadowView.hidden = true
            weatherImageViewContainer.hidden = true
            
        } else {
            shadowView.hidden = false
            weatherImageViewContainer.hidden = false
            refreshShadow()
        }
        
        isShadowShowing = !isShadowShowing
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowCalendar" {
            
            let destinationVC = segue.destinationViewController as! CalendarViewController
            
            destinationVC.delegate = self
            
        }
        
        
    }
    

}




// MARK: - MKMapViewDelegate

extension MapLocationViewController: MKMapViewDelegate {
    
    
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



extension MapLocationViewController: CalendarViewControllerDelegate {
    
    func dateSelected(date: NSDate) {
        
        diffComponents = calend.components([.Day], fromDate: NSDate(), toDate: date, options: [])
        
        if abs(diffComponents.day) > 5 {
            print("USING SUNRISE-SUNSET API")
            
        } else {
            print("USING FORECAST.IO API")

        }
        
        
        weatherDate = date
        
        refreshDateButton()

    }
    
    
}









