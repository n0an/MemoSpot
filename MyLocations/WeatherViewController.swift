//
//  WeatherViewController.swift
//  MyLocations
//
//  Created by Anton Novoselov on 15/07/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    let swipeRec = UISwipeGestureRecognizer()
    
    //Current Weather outlets
    @IBOutlet weak var windBag: UIImageView!
    @IBOutlet weak var umbrella: UIImageView!
    @IBOutlet weak var rainDrop: UIImageView!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    
    //@IBOutlet weak var currentTimeLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var precipitationLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    //@IBOutlet weak var refreshActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var degreeButton: UIButton!
    @IBOutlet weak var swipeView: UIView!
    @IBOutlet weak var heatIndex: UIImageView!
    @IBOutlet weak var dayZeroTemperatureLowLabel: UILabel!
    @IBOutlet weak var dayZeroTemperatureHighLabel: UILabel!
    
    @IBOutlet weak var windUILabel: UILabel!
    @IBOutlet weak var rainUILabel: UILabel!
    @IBOutlet weak var humidityUILabel: UILabel!
    
    //Daily Weather outlets
    
    @IBOutlet weak var dayZeroTemperatureLow: UILabel!
    @IBOutlet weak var dayZeroTemperatureHigh: UILabel!
    
    @IBOutlet weak var dayOneWeekDayLabel: UILabel!
    @IBOutlet weak var dayOneHighLow: UILabel!
    @IBOutlet weak var dayOneImage: UIImageView!
    
    @IBOutlet weak var dayTwoWeekDayLabel: UILabel!
    @IBOutlet weak var dayTwoHighLow: UILabel!
    @IBOutlet weak var dayTwoImage: UIImageView!
    
    @IBOutlet weak var dayThreeWeekDayLabel: UILabel!
    @IBOutlet weak var dayThreeHighLow: UILabel!
    @IBOutlet weak var dayThreeImage: UIImageView!
    
    @IBOutlet weak var dayFourWeekDayLabel: UILabel!
    @IBOutlet weak var dayFourHighLow: UILabel!
    @IBOutlet weak var dayFourImage: UIImageView!
    
    @IBOutlet weak var dayFiveWeekDayLabel: UILabel!
    @IBOutlet weak var dayFiveHighLow: UILabel!
    @IBOutlet weak var dayFiveImage: UIImageView!
    
    @IBOutlet weak var daySixWeekDayLabel: UILabel!
    @IBOutlet weak var daySixHighLow: UILabel!
    @IBOutlet weak var daySixImage: UIImageView!
    
    //Alerts
    
    @IBOutlet weak var wAlerts: UILabel!
    
    var seenError : Bool = false
    var locationFixAchieved : Bool = false
    var locationStatus : NSString = "Not Started"
    var locationManager: CLLocationManager!
    var userLocation : String!
    var userLatitude : Double!
    var userLongitude : Double!
    var userTemperatureCelsius : Bool!
    
    var locationToEdit: Location!

    
    private let apiKey = "da80aefa4ec207511622f3af58b36013"  // https://developer.forecast.io

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTemperatureCelsius = true

        swipeRec.addTarget(self, action: #selector(WeatherViewController.swipedView))
        swipeRec.direction = UISwipeGestureRecognizerDirection.Down
        swipeView.addGestureRecognizer(swipeRec)

        refresh()
        
        let addressLine = stringFromPlacemark(locationToEdit.placemark!)
        
        userLocationLabel.text = "\(addressLine)"

    }

    
    // MARK: - HELPER METHODS
    
    func swipedView(){
        
        refresh()
        
    }
    

    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        
        var line = ""
 
        line.addText(placemark.locality, withSeparator: ", ")
        
        line.addText(placemark.country, withSeparator: ", ")
        
        return line
        
    }

    
    
    
    // MARK: - WEATHER METHODS
    
    func getCurrentWeatherData() -> Void {
        
        userLatitude = locationToEdit.coordinate.latitude
        userLongitude = locationToEdit.coordinate.longitude
        
        userLocation = "\(userLatitude),\(userLongitude)"
        
        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        let forecastURL = NSURL(string: "\(userLocation)", relativeToURL:baseURL)
        
        
        let sharedSession = NSURLSession.sharedSession()
        
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(forecastURL!, completionHandler: { (location: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in
            
            
            if (error == nil) {
                
                let dataObject = NSData(contentsOfURL: location!)
                let weatherDictionary: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(dataObject!, options: [])) as! NSDictionary
                
                let currentWeather = CurrentWeather(weatherDictionary: weatherDictionary)
                let weeklyWeather = WeeklyWeather(weatherDictionary: weatherDictionary)
                
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    
                    if self.userTemperatureCelsius == true {
                        self.temperatureLabel.text = "\(Fahrenheit2Celsius(currentWeather.temperature))"
                    } else {
                        self.temperatureLabel.text = "\(currentWeather.temperature)"
                    }
                    
                    self.iconView.image = currentWeather.icon
                    //self.currentTimeLabel.text = "\(currentWeather.currentTime!)"
                    self.humidityLabel.text = "\(currentWeather.humidity)"
                    self.precipitationLabel.text = "\(currentWeather.precipProbability)"
                    self.summaryLabel.text = "\(currentWeather.summary)"
                    self.windSpeedLabel.text = "\(currentWeather.windSpeed)"
                    
                    if self.userTemperatureCelsius == true {
                        self.dayZeroTemperatureHigh.text = "\(Fahrenheit2Celsius(weeklyWeather.dayZeroTemperatureMax))"
                        self.dayZeroTemperatureLow.text = "\(Fahrenheit2Celsius(weeklyWeather.dayZeroTemperatureMin))"
                    } else {
                        self.temperatureLabel.text = "\(currentWeather.temperature)"
                        self.dayZeroTemperatureHigh.text = "\(weeklyWeather.dayZeroTemperatureMax)"
                        self.dayZeroTemperatureLow.text = "\(weeklyWeather.dayZeroTemperatureMin)"
                    }
                    
                    // Notification Statements
                    
                    if currentWeather.precipProbability == 1.0 {
                        
                    }
                    
                    if currentWeather.windSpeed > 38.0 {
                        
                    }
                    
                    if weeklyWeather.dayZeroTemperatureMax > 90 {
                        
                    }
                    
                    
                    
                    //HEAT INDEX
                    
                    if currentWeather.temperature < 60 {
                        self.heatIndex.image = UIImage(named: "heatindexWinter")
                        self.dayZeroTemperatureLow.textColor = UIColor(red: 0/255.0, green: 121/255.0, blue: 255/255.0, alpha: 1.0)
                        self.dayZeroTemperatureHigh.textColor = UIColor(red: 245/255.0, green: 6/255.0, blue: 93/255.0, alpha: 1.0)
                        
                        
                    } else {
                        self.heatIndex.image = UIImage(named:"heatindex")
                        
                    }
                    
                    
                    //7 day out look
                    
                    if self.userTemperatureCelsius == true {
                        self.dayOneHighLow.text = "\(Fahrenheit2Celsius(weeklyWeather.dayOneTemperatureMin))°/ \(Fahrenheit2Celsius(weeklyWeather.dayOneTemperatureMax))°"
                        
                        self.dayTwoHighLow.text = "\(Fahrenheit2Celsius(weeklyWeather.dayTwoTemperatureMin))°/ \(Fahrenheit2Celsius(weeklyWeather.dayTwoTemperatureMax))°"
                        
                        self.dayThreeHighLow.text = "\(Fahrenheit2Celsius(weeklyWeather.dayThreeTemperatureMin))°/ \(Fahrenheit2Celsius(weeklyWeather.dayThreeTemperatureMax))°"
                        
                        self.dayFourHighLow.text = "\(Fahrenheit2Celsius(weeklyWeather.dayFourTemperatureMin))°/ \(Fahrenheit2Celsius(weeklyWeather.dayFourTemperatureMax))°"
                        
                        self.dayFiveHighLow.text = "\(Fahrenheit2Celsius(weeklyWeather.dayFiveTemperatureMin))°/ \(Fahrenheit2Celsius(weeklyWeather.dayFiveTemperatureMax))°"
                        
                        self.daySixHighLow.text = "\(Fahrenheit2Celsius(weeklyWeather.daySixTemperatureMin))°/ \(Fahrenheit2Celsius(weeklyWeather.daySixTemperatureMax))°"
                        
                    } else {
                        self.dayOneHighLow.text = "\(weeklyWeather.dayOneTemperatureMin)°/ \(weeklyWeather.dayOneTemperatureMax)°"
                        self.dayTwoHighLow.text = "\(weeklyWeather.dayTwoTemperatureMin)°/ \(weeklyWeather.dayTwoTemperatureMax)°"
                        self.dayThreeHighLow.text = "\(weeklyWeather.dayThreeTemperatureMin)°/ \(weeklyWeather.dayThreeTemperatureMax)°"
                        self.dayFourHighLow.text = "\(weeklyWeather.dayFourTemperatureMin)°/ \(weeklyWeather.dayFourTemperatureMax)°"
                        self.dayFiveHighLow.text = "\(weeklyWeather.dayFiveTemperatureMin)°/ \(weeklyWeather.dayFiveTemperatureMax)°"
                        self.daySixHighLow.text = "\(weeklyWeather.daySixTemperatureMin)°/ \(weeklyWeather.daySixTemperatureMax)°"
                    }
                    
                    
                    
                    self.dayOneWeekDayLabel.text = "\(weeklyWeather.dayOneTime!)"
                    self.dayOneImage.image = weeklyWeather.dayOneIcon
                    
                    self.dayTwoWeekDayLabel.text = "\(weeklyWeather.dayTwoTime!)"
                    self.dayTwoImage.image = weeklyWeather.dayTwoIcon
                    
                    self.dayThreeWeekDayLabel.text = "\(weeklyWeather.dayThreeTime!)"
                    self.dayThreeImage.image = weeklyWeather.dayThreeIcon
                    
                    self.dayFourWeekDayLabel.text = "\(weeklyWeather.dayFourTime!)"
                    self.dayFourImage.image = weeklyWeather.dayFourIcon
                    
                    self.dayFiveWeekDayLabel.text = "\(weeklyWeather.dayFiveTime!)"
                    self.dayFiveImage.image = weeklyWeather.dayFiveIcon
                    
                    self.daySixWeekDayLabel.text = "\(weeklyWeather.daySixTime!)"
                    self.daySixImage.image = weeklyWeather.dayFiveIcon
                    
                    //Weather Alerts
                    self.wAlerts.text = ""
                    
                })
                
            } else {
                
                
            }
            
        })
        
        downloadTask.resume()
        
        
    }

    
    
    
    func refresh() {
        
        getCurrentWeatherData()
        
        self.temperatureLabel.alpha = 0
        self.dayOneImage.alpha = 0
        self.dayTwoImage.alpha = 0
        self.dayThreeImage.alpha = 0
        self.dayFourImage.alpha = 0
        self.dayFiveImage.alpha = 0
        self.daySixImage.alpha = 0
        self.dayZeroTemperatureLow.alpha = 0
        self.dayZeroTemperatureHigh.alpha = 0
        self.windSpeedLabel.alpha = 0
        self.humidityLabel.alpha = 0
        self.precipitationLabel.alpha = 0
        self.rainUILabel.alpha = 0
        self.dayOneWeekDayLabel.alpha = 0
        self.dayOneHighLow.alpha = 0
        self.dayTwoWeekDayLabel.alpha = 0
        self.dayTwoHighLow.alpha = 0
        self.dayThreeWeekDayLabel.alpha = 0
        self.dayThreeHighLow.alpha = 0
        self.dayFourWeekDayLabel.alpha = 0
        self.dayFourHighLow.alpha = 0
        self.dayFiveWeekDayLabel.alpha = 0
        self.dayFiveHighLow.alpha = 0
        self.daySixWeekDayLabel.alpha = 0
        self.daySixHighLow.alpha = 0
        self.wAlerts.alpha = 0
        
        
        UIView.animateWithDuration(1.5, animations: {
            self.temperatureLabel.alpha = 1.0
            self.heatIndex.alpha = 1.0
            self.dayOneImage.alpha = 1.0
            self.dayTwoImage.alpha = 1.0
            self.dayThreeImage.alpha = 1.0
            self.dayFourImage.alpha = 1.0
            self.dayFiveImage.alpha = 1.0
            self.daySixImage.alpha = 1.0
            self.dayZeroTemperatureLow.alpha = 1.0
            self.dayZeroTemperatureHigh.alpha = 1.0
            self.windSpeedLabel.alpha = 1.0
            self.humidityLabel.alpha = 1.0
            self.precipitationLabel.alpha = 1.0
            self.rainUILabel.alpha = 1.0
            self.dayOneWeekDayLabel.alpha = 1.0
            self.dayOneHighLow.alpha = 1.0
            self.dayTwoWeekDayLabel.alpha = 1.0
            self.dayTwoHighLow.alpha = 1.0
            self.dayThreeWeekDayLabel.alpha = 1.0
            self.dayThreeHighLow.alpha = 1.0
            self.dayFourWeekDayLabel.alpha = 1.0
            self.dayFourHighLow.alpha = 1.0
            self.dayFiveWeekDayLabel.alpha = 1.0
            self.dayFiveHighLow.alpha = 1.0
            self.daySixWeekDayLabel.alpha = 1.0
            self.daySixHighLow.alpha = 1.0
            self.wAlerts.alpha = 1.0
            
        })
    }
    
    
    
}












