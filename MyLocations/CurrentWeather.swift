//
//  CurrentWeather.swift
//  MyLocations
//
//  Created by Anton Novoselov on 12/07/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//


import UIKit

struct CurrentWeather {
    
    var currentTime: String?
    var currentUnixTime: Int
    var temperature: Int
    var humidity: Double
    var precipProbability: Double
    var summary: String
    var icon: UIImage
    var altIcon: UIImage
    var windSpeed: Double
    
    var isClearDay = false
    
    init (weatherDictionary: NSDictionary) {
        
        let currentWeather = weatherDictionary["currently"] as! NSDictionary
        
        temperature         = currentWeather["temperature"] as! Int
        humidity            = currentWeather["humidity"]as! Double
        precipProbability   = currentWeather["precipProbability"] as! Double
        summary             = currentWeather["summary"]as! String
        windSpeed           = currentWeather["windSpeed"]as! Double
        
        let currentTimeIntValue = currentWeather["time"]as! Int
        currentUnixTime = currentTimeIntValue
        
        currentTime = dateStringFromUnixtime(currentTimeIntValue)
        
        let iconString = currentWeather["icon"]as! String
        
        icon = weatherIconFromString(iconString)
        altIcon = altWeatherIconFromString(iconString)
        
        isClearDay = isItClearDay(iconString)
        
        
    }
}


//Date formatter

func dateStringFromUnixtime(_ unixTime: Int) -> String {
    
    let timeInSeconds = TimeInterval(unixTime)
    let weatherDate = Date(timeIntervalSince1970: timeInSeconds)
    
    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = .medium
    
    return dateFormatter.string(from: weatherDate)
    
    
}


//Images


func weatherIconFromString(_ stringIcon: String) -> UIImage {
    
    let imageName = processString(stringIcon)
    
    let iconImage = UIImage(named: imageName)
    return iconImage!
    
}

func altWeatherIconFromString(_ stringIcon: String) -> UIImage {
    
    let imageName = processString(stringIcon) + "-alt"
    
    let iconImage = UIImage(named: imageName)
    
    return iconImage!
    
    
}

func processString(_ inputStr: String) -> String {
    
    var imageName: String
    
    switch inputStr {
    case "clear-day":
        imageName = "clear-day"
        
    case "clear-night":
        imageName = "clear-night"
        
    case "rain":
        imageName = "rain"
        
    case "snow":
        imageName = "snow"
        
    case "sleet":
        imageName = "sleet"
        
    case "wind":
        imageName = "wind"
        
    case "fog":
        imageName = "fog"
        
    case "cloudy":
        imageName = "cloudy"
        
    case "partly-cloudy-day":
        imageName = "partly-cloudy"
        
    case "partly-cloudy-night":
        imageName = "cloudy-night"
        
    default:
        imageName = "default"
    }
    
    return imageName

}


func isItClearDay(_ stringIcon: String) -> Bool {
    
    switch stringIcon {
    case "clear-day", "clear-night", "partly-cloudy-day", "partly-cloudy-night":
        return true
        
    default:
        return false
    }
    
    
    
}




func Fahrenheit2Celsius(_ f: Int) -> Int {
    return Int((Double(f) - 32.0) / 1.8)
}




