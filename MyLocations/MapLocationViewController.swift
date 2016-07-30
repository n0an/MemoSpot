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
    
    
    
    // MARK: - FLAGS
    
    var isWeatherAvailable = true
    
    var isShadowShowing = false
    
    var isClearDay = false
    
    // MARK: - PROPERTIES

    var currentWeather: CurrentWeather!
    var weather: WeeklyWeather!
    var sunriseSunset: SunriseSunset!
    
    var iconsDict:[Int:(UIImage, Bool)]!
    
    var locationToEdit: Location!
    var locations = [Location]()

    var currentAngle: CGFloat = 0
    var shadowWidth: CGFloat!
    
    var shadowView: UIImageView!
    
    var sunriseTime: Int!
    var sunsetTime: Int!
    
    var altSunriseTime: String!
    var altSunsetTime: String!
    
    var dayLightSpan: Int!
    
    var deltaAngel: CGFloat!
    
    var weatherDate = NSDate()

    let calend = ANConfigurator.sharedConfigurator.calendar
    
    var components: NSDateComponents!
    
    var diffComponents: NSDateComponents!
    
    var currentAlpha: CGFloat!
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        initShadowView()

        updateLocations()

        if !locations.isEmpty {
            showLocations()
        }
        
        components = calend.components([.Month, .Day], fromDate: weatherDate)
        
        refreshDateButton()
        
        ANConfigurator.sharedConfigurator.customizeSlider(timeSlider)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
     
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if isWeatherAvailable {
            getCurrentWeatherData()
            
        } else {
            getSuriseSunsetAlternative()
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
    
    
    func altCalculateTimeStamps() {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        let sunriseComponents = altSunriseTime.componentsSeparatedByString(":")
        let sunsetComponents = altSunsetTime.componentsSeparatedByString(":")
        
        sunriseTime = Int(sunriseComponents[0])! + weather.offset
        sunsetTime = Int(sunsetComponents[0])! + weather.offset
        
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
        
        if !isClearDay {
            shadowView.alpha = 0.4
        } else {
            shadowView.alpha = 1.0
        }
        currentAlpha = shadowView.alpha
        
        let selectedTime = Int(timeSlider.value * 24)
        
        if selectedTime >= sunriseTime && selectedTime <= sunsetTime {
            
            shadowView?.hidden = false
            
            
            let slowSunTime = dayLightSpan / 10
            
            let isMorningTime = (selectedTime - sunriseTime) <= slowSunTime
            let isEveningTime = (sunsetTime - selectedTime) <= slowSunTime

            
            if isMorningTime || isEveningTime {

                shadowView.alpha = currentAlpha * 0.3
            
            } else {
                
                shadowView.alpha = currentAlpha
            }
            
            
            let currentAngle = CGFloat(selectedTime - sunriseTime!) * deltaAngel
            
            let doubleDayLightSpan = Double(dayLightSpan)
            
            let currentWidth = pow((Double(selectedTime - sunriseTime!) - doubleDayLightSpan/2), 2)*Double(877/pow(doubleDayLightSpan, 2)) + 30
            
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
    
    func getSuriseSunsetAlternative() {
        
        let alternativeDateFormatter = NSDateFormatter()
        
        alternativeDateFormatter.dateFormat = "YYYY-MM-dd"
        
        let locationString = "lat=\(locationToEdit.coordinate.latitude)&lng=\(locationToEdit.coordinate.longitude)"
        
        let suffixStr = "&date=\(alternativeDateFormatter.stringFromDate(weatherDate))&formatted=0"
        
        let url = NSURL(string: "http://api.sunrise-sunset.org/json?\(locationString)\(suffixStr)")
        
        let sharedSession = NSURLSession.sharedSession()
        
        
        
        let dataTask = sharedSession.dataTaskWithURL(url!) { (data, response, error) in
            
            if (error == nil) {
                
                let dataObject = data
                
                let responseDictionary: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(dataObject!, options: [])) as! NSDictionary
                
                self.sunriseSunset = SunriseSunset(responseDictionary: responseDictionary)
                
                self.altSunriseTime = self.sunriseSunset.sunriseTime
                self.altSunsetTime = self.sunriseSunset.sunsetTime
                
                self.altCalculateTimeStamps()
                
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    if self.isShadowShowing {
                        self.refreshShadow()
                    }
                    
                    
                })
                
                
            } else {
                
                
            }
            
            
        }
        
        dataTask.resume()
        
        
        
        
    }
    
    
    
    func getCurrentWeatherData() -> Void {
        
        guard weather==nil else {
            refreshWeatherUI()
            return
        }
        
        let userLocation = "\(locationToEdit.coordinate.latitude),\(locationToEdit.coordinate.longitude)"
        
        print(userLocation)
        
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
                self.currentWeather = currentWeather
                
                self.iconsDict =
                    [currentWeather.currentUnixTime:(currentWeather.icon, currentWeather.isClearDay),
                    weeklyWeather.dayOneUnixTime:(weeklyWeather.dayOneIcon, weeklyWeather.dayOneIsClear),
                    weeklyWeather.dayTwoUnixTime:(weeklyWeather.dayTwoIcon, weeklyWeather.dayTwoIsClear),
                    weeklyWeather.dayThreeUnixTime:(weeklyWeather.dayThreeIcon, weeklyWeather.dayThreeIsClear),
                    weeklyWeather.dayFourUnixTime:(weeklyWeather.dayFourIcon, weeklyWeather.dayFourIsClear),
                    weeklyWeather.dayFiveUnixTime:(weeklyWeather.dayFiveIcon, weeklyWeather.dayFiveIsClear),
                    weeklyWeather.daySixUnixTime:(weeklyWeather.daySixIcon, weeklyWeather.daySixIsClear)]
                
                self.isClearDay = currentWeather.isClearDay
                
//                print(weatherDictionary)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.getSuriseSunsetAlternative()
                    
//                    self.calculateTimeStamps()
                    
//                    self.weatherImageView.image = self.weather.dayZeroIcon
                    
                    self.weatherImageView.image = self.currentWeather.icon
                    
                    

                    
                    if self.isShadowShowing {
                        self.refreshShadow()
                        self.weatherImageViewContainer.hidden = false
                    }

                })
                
                
                
            } else {
                
                
            }
            
        })
        
        downloadTask.resume()
        
    }
    
    
    
    func refreshWeatherUI() {
        self.getSuriseSunsetAlternative()
        
        // Getting nearest sunrise time
        
        let times = iconsDict.keys
        
        var min = NSTimeInterval(INT_MAX)
        
        var minTime = 0
        
        for time in times {
            print("time = \(time)")
            
            let sunriseTimeInSeconds = NSTimeInterval(time)
            
            let sunriseDate = NSDate(timeIntervalSince1970: sunriseTimeInSeconds)
            
            let unixTime = abs(weatherDate.timeIntervalSinceDate(sunriseDate))
            
            if unixTime < min {
                min = unixTime
                
                minTime = time
            }
        
        }
        print("min = \(min)")

        print("minTime = \(minTime)")

        let tuple = iconsDict[minTime]
        
        let icon = tuple?.0
        
        self.weatherImageView.image = icon!
        
        let isClearSelectedDay = tuple!.1
        
        isClearDay = isClearSelectedDay
        
        if self.isShadowShowing {
            self.refreshShadow()
            self.weatherImageViewContainer.hidden = false
        }
        
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
            
            
            if isWeatherAvailable {
                weatherImageViewContainer.hidden = false
            } else {
                weatherImageViewContainer.hidden = true
            }
            
            refreshShadow()
        }
        
        isShadowShowing = !isShadowShowing
        
    }
    
    // MARK: - NAVIGATION
    
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
        
        print("diffComponents.day = \(diffComponents.day)")
        
        if 0 > diffComponents.day || diffComponents.day > 5 {
            print("USING SUNRISE-SUNSET API")
            
            isWeatherAvailable = false
            isClearDay = true
            weatherImageViewContainer.hidden = true
            
            
        } else {
            print("USING FORECAST.IO API")
            
            isWeatherAvailable = true

        }
        
        
        weatherDate = date
        
        refreshDateButton()

    }
    
    
}









