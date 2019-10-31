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
    
    var weatherDate = Date()

    let calend = ANConfigurator.sharedConfigurator.calendar
    
    var components: DateComponents!
    
    var diffComponents: DateComponents!
    
    var currentAlpha: CGFloat!
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        initShadowView()

        updateLocations()

        if !locations.isEmpty {
            showLocations()
        }
        
        components = (calend as NSCalendar).components([.month, .day], from: weatherDate)
        
        refreshDateButton()
        
        ANConfigurator.sharedConfigurator.customizeSlider(timeSlider)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    @objc func showLocationDetails(_ sender: UIButton) {
        
    }

    
    
    func calculateTimeStamps() {
        
        let sunriseTimeInSeconds = TimeInterval(weather.sunriseTime)
        let sunsetTimeInSeconds = TimeInterval(weather.sunsetTime)
        
        let sunriseDate = Date(timeIntervalSince1970: sunriseTimeInSeconds)
        let sunsetDate = Date(timeIntervalSince1970: sunsetTimeInSeconds)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        
        sunriseTime = Int(dateFormatter.string(from: sunriseDate))
        sunsetTime = Int(dateFormatter.string(from: sunsetDate))
        
        if let sunsetT = sunsetTime, let sunriseT = sunriseTime {
            
            dayLightSpan = sunsetT - sunriseT
            
            deltaAngel = CGFloat(M_PI) / CGFloat(dayLightSpan)
            
        } else {
            
            deltaAngel = 0

        }
        
        
        
    }
    
    
    func altCalculateTimeStamps() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        let sunriseComponents = altSunriseTime.components(separatedBy: ":")
        let sunsetComponents = altSunsetTime.components(separatedBy: ":")
        
        
        if let comp1 = Int(sunriseComponents[0]), let comp2 = Int(sunsetComponents[0]) {
            
            sunriseTime = comp1 + weather.offset
            sunsetTime = comp2 + weather.offset
            
            
            if let sunsetT = sunsetTime, let sunriseT = sunriseTime {
                
                dayLightSpan = sunsetT - sunriseT
                
                deltaAngel = CGFloat(M_PI) / CGFloat(dayLightSpan)
                
            } else {
                
                deltaAngel = 0
                
            }
        }
        
        
        
        
        
    }
    
    func initShadowView() {
        
        let shadowImageView = UIImageView(image: UIImage(named: "shadowArrow"))
        shadowImageView.frame.origin = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        
        view.addSubview(shadowImageView)
        
        shadowView = shadowImageView
        
        shadowView.isHidden = true
        
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
            
            shadowView?.isHidden = false
            
            
            let slowSunTime = dayLightSpan / 10
            
            let isMorningTime = (selectedTime - sunriseTime) <= slowSunTime
            let isEveningTime = (sunsetTime - selectedTime) <= slowSunTime

            
            if isMorningTime || isEveningTime {

                shadowView.alpha = currentAlpha * 0.3
            
            } else {
                
                shadowView.alpha = currentAlpha
            }
            
            
            if let sunriseT = sunriseTime {
                
                let currentAngle = CGFloat(selectedTime - sunriseT) * deltaAngel
                
                let doubleDayLightSpan = Double(dayLightSpan)
                
                let currentWidth = pow((Double(selectedTime - sunriseT) - doubleDayLightSpan/2), 2)*Double(877/pow(doubleDayLightSpan, 2)) + 30
                
                shadowView?.transform = CGAffineTransform(rotationAngle: currentAngle)
                
                shadowView?.bounds.size.width = CGFloat(currentWidth)
            }
            
            
        } else {
            
            shadowView?.isHidden = true
            
        }
        
        

    }
    
    
    func refreshDateButton() {
        
        let dateString = ANConfigurator.sharedConfigurator.dateFormatter.string(from: weatherDate)
        
        dateButton.setTitle(dateString, for: UIControl.State())
    }
    
    
    
    
    // MARK: - WEATHER METHODS
    
    func getSuriseSunsetAlternative() {
        
        let alternativeDateFormatter = DateFormatter()
        
        alternativeDateFormatter.dateFormat = "YYYY-MM-dd"
        
        let locationString = "lat=\(locationToEdit.coordinate.latitude)&lng=\(locationToEdit.coordinate.longitude)"
        
        let suffixStr = "&date=\(alternativeDateFormatter.string(from: weatherDate))&formatted=0"
        
        let url = URL(string: "http://api.sunrise-sunset.org/json?\(locationString)\(suffixStr)")
        
        let sharedSession = URLSession.shared
        
        guard let pUrl = url else { return }
        
        
        let dataTask = sharedSession.dataTask(with: pUrl, completionHandler: { (data, response, error) in
            
            if (error == nil) {
                
                let dataObject = data
                
                let responseDictionary: NSDictionary = (try! JSONSerialization.jsonObject(with: dataObject!, options: [])) as! NSDictionary
                
                self.sunriseSunset = SunriseSunset(responseDictionary: responseDictionary)
                
                self.altSunriseTime = self.sunriseSunset.sunriseTime
                self.altSunsetTime = self.sunriseSunset.sunsetTime
                
                self.altCalculateTimeStamps()
                
                
                DispatchQueue.main.async(execute: {
                    
                    if self.isShadowShowing {
                        self.refreshShadow()
                    }
                    
                    
                })
                
                
            } else {
                
                
            }
            
            
        }) 
        
        dataTask.resume()
        
        
        
        
    }
    
    
    
    func getCurrentWeatherData() -> Void {
        
        guard weather==nil else {
            refreshWeatherUI()
            return
        }
        
        let userLocation = "\(locationToEdit.coordinate.latitude),\(locationToEdit.coordinate.longitude)"
        
        
        let baseURL = URL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        let forecastURL = URL(string: "\(userLocation)", relativeTo:baseURL)
        
        
        let sharedSession = URLSession.shared
        
        let downloadTask: URLSessionDownloadTask = sharedSession.downloadTask(with: forecastURL!, completionHandler: { (location: URL?, response: URLResponse?, error: NSError?) -> Void in
            
            if (error == nil) {
                
                let dataObject = try? Data(contentsOf: location!)
                let weatherDictionary: NSDictionary = (try! JSONSerialization.jsonObject(with: dataObject!, options: [])) as! NSDictionary
                
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
                
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    self.getSuriseSunsetAlternative()
                    
                    self.weatherImageView.image = self.currentWeather.icon
                    
                    if self.isShadowShowing {
                        self.refreshShadow()
                        self.weatherImageViewContainer.isHidden = false
                    }

                })
                
                
                
            } else {
                
                
            }
            
        } as! (URL?, URLResponse?, Error?) -> Void)
        
        downloadTask.resume()
        
    }
    
    
    
    func refreshWeatherUI() {
        self.getSuriseSunsetAlternative()
        
        // Getting nearest sunrise time
        
        let times = iconsDict.keys
        
        var min = TimeInterval(INT_MAX)
        
        var minTime = 0
        
        for time in times {
            
            let sunriseTimeInSeconds = TimeInterval(time)
            
            let sunriseDate = Date(timeIntervalSince1970: sunriseTimeInSeconds)
            
            let unixTime = abs(weatherDate.timeIntervalSince(sunriseDate))
            
            if unixTime < min {
                min = unixTime
                
                minTime = time
            }
        
        }

        let tuple = iconsDict[minTime]
        
        let icon = tuple?.0
        
        if let pIcon = icon {
            
            self.weatherImageView.image = pIcon
        }
        
        
        let isClearSelectedDay = tuple?.1
        
        if let isClear = isClearSelectedDay {
            
            isClearDay = isClear
        }
        
        
        if self.isShadowShowing {
            self.refreshShadow()
            self.weatherImageViewContainer.isHidden = false
        }
        
    }

    
    
    
    // MARK: - ACTIONS
    
    @IBAction func actionTimeSliderValueChanged(_ sender: UISlider) {
        
        timeLabel.text = "\(Int(sender.value * 24)):00"
        
        guard isShadowShowing else {return}
        
        refreshShadow()
        
    }
    
    
    
    @IBAction func showShadows(_ sender: UIBarButtonItem) {
        
        if isShadowShowing {
            shadowView.isHidden = true
            weatherImageViewContainer.isHidden = true
            
        } else {
            shadowView.isHidden = false
            
            
            if isWeatherAvailable {
                weatherImageViewContainer.isHidden = false
            } else {
                weatherImageViewContainer.isHidden = true
            }
            
            refreshShadow()
        }
        
        isShadowShowing = !isShadowShowing
        
    }
    
    // MARK: - NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowCalendar" {
            
            let destinationVC = segue.destination as! CalendarViewController
            
            destinationVC.delegate = self
            
        }
        
        
    }
    
    
}




// MARK: - MKMapViewDelegate

extension MapLocationViewController: MKMapViewDelegate {
    
    
    func regionForAnnotations(_ annotations: [MKAnnotation]) -> MKCoordinateRegion {
        
        var region: MKCoordinateRegion
        
        switch annotations.count {
            
        case 0:
            region = MKCoordinateRegion.init( center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            
        case 1:
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegion.init(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            
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
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is Location else { return nil }
        
        let identifier = "Location"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as! MKPinAnnotationView?
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            annotationView?.isEnabled = true
            annotationView?.canShowCallout = true
            annotationView?.animatesDrop = false
            if #available(iOS 9.0, *) {
                annotationView?.pinTintColor = UIColor(red: 0.32, green: 0.82, blue: 0.4, alpha: 1)
            } else {
                
            }
            
            annotationView?.tintColor = UIColor(white: 0.0, alpha: 0.5)
            
            
            let rightButton = UIButton(type: .detailDisclosure)
            rightButton.addTarget(self, action: #selector(MapLocationViewController.showLocationDetails(_:)), for: .touchUpInside)
            
            annotationView?.rightCalloutAccessoryView = rightButton
            
        } else { 
            
            annotationView?.annotation = annotation
            
        }
        
        let button = annotationView?.rightCalloutAccessoryView as! UIButton
        
        if let index = locations.firstIndex(of: annotation as! Location) {
            button.tag = index
        }
        
        return annotationView
        
        
    }
    
    
}



extension MapLocationViewController: CalendarViewControllerDelegate {
    
    func dateSelected(_ date: Date) {
        
        diffComponents = (calend as NSCalendar).components([.day], from: Date(), to: date, options: [])
        
        
        if 0 > diffComponents.day! || diffComponents.day! > 5 {
            
            isWeatherAvailable = false
            isClearDay = true
            weatherImageViewContainer.isHidden = true
            
            
        } else {
            
            isWeatherAvailable = true

        }
        
        weatherDate = date
        
        refreshDateButton()

    }
    
    
}









