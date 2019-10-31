//
//  HourlyWeather.swift
//  MyLocations
//
//  Created by Anton Novoselov on 14/07/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit


struct HourlyWeather {
    
    var hourZeroTemperature: Int = 0
    var hourZeroTime: String?
    
    var hourZeroIcon: UIImage = UIImage(contentsOfFile: "tmp")!

    
    var hourOneTemperature: Int = 0
    var hourOneTime: String?
    
    var hourOneIcon: UIImage = UIImage(contentsOfFile: "tmp")!
    
    var hourTwoTemperature: Int = 0
    var hourTwoTime: String?
    
    var hourTwoIcon: UIImage = UIImage(contentsOfFile: "tmp")!
    
    var hourThreeTemperature: Int = 0
    var hourThreeTime: String?
    
    var hourThreeIcon: UIImage = UIImage(contentsOfFile: "tmp")!
    
    var hourFourTemperature: Int = 0
    var hourFourTime: String?
    
    var hourFourIcon: UIImage = UIImage(contentsOfFile: "tmp")!
    
    var hourFiveTemperature: Int = 0
    var hourFiveTime: String?
    
    var hourFiveIcon: UIImage = UIImage(contentsOfFile: "tmp")!
    
    var hourSixTemperature: Int = 0
    var hourSixTime: String?
    
    var hourSixIcon: UIImage = UIImage(contentsOfFile: "tmp")!
    
    
    init (weatherDictionary: NSDictionary) {
        
        let hourlyWeather = weatherDictionary["hourly"] as! NSDictionary
        
        let hourlyForecast = hourlyWeather["data"] as! NSArray
        
        
        
        
        //hour ZERO
//        let hourZeroTimeIntValue = hourlyForecast[0]["time"] as! Int
//
//        hourZeroTime = timeStringFromUnixtime(hourZeroTimeIntValue)
//
//        hourZeroTemperature = hourlyForecast[0]["temperature"] as! Int
//
//        let hourZeroIconString = hourlyForecast[0]["icon"] as! String
//        hourZeroIcon = weatherIconFromString(hourZeroIconString)
//
//
//        //hour ONE
//        let hourOneTimeIntValue = hourlyForecast[1]["time"] as! Int
//
//        hourOneTime = timeStringFromUnixtime(hourOneTimeIntValue)
//
//        hourOneTemperature = hourlyForecast[1]["temperature"] as! Int
//
//        let hourOneIconString = hourlyForecast[1]["icon"] as! String
//        hourOneIcon = weatherIconFromString(hourOneIconString)
//
//
//
//        //hour TWO
//        let hourTwoTimeIntValue = hourlyForecast[2]["time"] as! Int
//
//        hourTwoTime = timeStringFromUnixtime(hourTwoTimeIntValue)
//
//        hourTwoTemperature = hourlyForecast[2]["temperature"] as! Int
//
//        let hourTwoIconString = hourlyForecast[2]["icon"] as! String
//        hourTwoIcon = weatherIconFromString(hourTwoIconString)
//
//
//        //hour THREE
//        let hourThreeTimeIntValue = hourlyForecast[3]["time"] as! Int
//
//        hourThreeTime = timeStringFromUnixtime(hourThreeTimeIntValue)
//
//        hourThreeTemperature = hourlyForecast[3]["temperature"] as! Int
//
//        let hourThreeIconString = hourlyForecast[3]["icon"] as! String
//        hourThreeIcon = weatherIconFromString(hourThreeIconString)
//
//
//        //hour FOUR
//        let hourFourTimeIntValue = hourlyForecast[4]["time"] as! Int
//
//        hourFourTime = timeStringFromUnixtime(hourFourTimeIntValue)
//
//        hourFourTemperature = hourlyForecast[4]["temperature"] as! Int
//
//        let hourFourIconString = hourlyForecast[4]["icon"] as! String
//        hourFourIcon = weatherIconFromString(hourFourIconString)
//
//
//        //hour FIVE
//        let hourFiveTimeIntValue = hourlyForecast[5]["time"] as! Int
//
//        hourFiveTime = timeStringFromUnixtime(hourFiveTimeIntValue)
//
//        hourFiveTemperature = hourlyForecast[5]["temperature"] as! Int
//
//        let hourFiveIconString = hourlyForecast[5]["icon"] as! String
//        hourFiveIcon = weatherIconFromString(hourFiveIconString)
//
//
//        //hour SIX
//        let hourSixTimeIntValue = hourlyForecast[6]["time"] as! Int
//
//        hourSixTime = timeStringFromUnixtime(hourSixTimeIntValue)
//
//        hourSixTemperature = hourlyForecast[6]["temperature"] as! Int
//
//        let hourSixIconString = hourlyForecast[6]["icon"] as! String
//        hourSixIcon = weatherIconFromString(hourSixIconString)
        
    }
    
    
}



func weeekDateStringFromUnixtime(_ unixTime: Int) -> String {
    
    let timeInSeconds = TimeInterval(unixTime)
    let weatherDate = Date(timeIntervalSince1970: timeInSeconds)
    
    let dateFormatter = DateFormatter()
    //dateFormatter.timeStyle = .MediumStyle
    dateFormatter.dateFormat = "EEE"
    
    return dateFormatter.string(from: weatherDate)
    
    
}



//Time formatter

func timeStringFromUnixtime(_ unixTime: Int) -> String {
    
    let timeInSeconds = TimeInterval(unixTime)
    let weatherDate = Date(timeIntervalSince1970: timeInSeconds)
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    
    return dateFormatter.string(from: weatherDate)
    
    
}

