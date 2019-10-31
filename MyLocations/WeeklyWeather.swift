//
//  WeeklyWeather.swift
//  MyLocations
//
//  Created by Anton Novoselov on 12/07/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit


struct WeeklyWeather {
    
    var offset: Int
    
    var dayZeroTemperatureMax: Int = 0
    var dayZeroTemperatureMin: Int = 0
    
    var sunriseTime: Int = 0
    var sunsetTime: Int = 0
    
    var dayZeroIcon: UIImage = UIImage(named: "tmp")!
    
    var dayOneTemperatureMax: Int = 0
    var dayOneTemperatureMin: Int = 0
    var dayOneTime: String?
    var dayOneUnixTime: Int = 0
    
    var dayOneIcon: UIImage = UIImage(named: "tmp")!
    var dayOneIsClear: Bool = true
    
    var dayTwoTemperatureMax: Int = 0
    var dayTwoTemperatureMin: Int = 0
    var dayTwoTime: String?
    var dayTwoUnixTime: Int = 0
    
    var dayTwoIcon: UIImage = UIImage(named: "tmp")!
    var dayTwoIsClear: Bool = true

    var dayThreeTemperatureMax: Int = 0
    var dayThreeTemperatureMin: Int = 0
    var dayThreeTime: String?
    var dayThreeUnixTime: Int = 0

    var dayThreeIcon: UIImage = UIImage(named: "tmp")!
    var dayThreeIsClear: Bool = true

    var dayFourTemperatureMax: Int = 0
    var dayFourTemperatureMin: Int = 0
    var dayFourTime: String?
    var dayFourUnixTime: Int = 0

    var dayFourIcon: UIImage = UIImage(named: "tmp")!
    var dayFourIsClear: Bool = true

    var dayFiveTemperatureMax: Int = 0
    var dayFiveTemperatureMin: Int = 0
    var dayFiveTime: String?
    var dayFiveUnixTime: Int = 0

    var dayFiveIcon: UIImage = UIImage(named: "tmp")!
    var dayFiveIsClear: Bool = true

    var daySixTemperatureMax: Int = 0
    var daySixTemperatureMin: Int = 0
    var daySixTime: String?
    var daySixUnixTime: Int = 0

    var daySixIcon: UIImage = UIImage(named: "tmp")!
    var daySixIsClear: Bool = true

    
    
    init (weatherDictionary: NSDictionary) {
        
        offset = weatherDictionary["offset"] as! Int
        
        let weeklyWeather = weatherDictionary["daily"] as! NSDictionary
        
        let weeklyForcast = weeklyWeather["data"] as! NSArray
        
//        sunriseTime = weeklyForcast[0]["sunriseTime"] as! Int
//
//        sunsetTime = weeklyForcast[0]["sunsetTime"] as! Int
//
//
//        //DAY ZERO
//        dayZeroTemperatureMax = weeklyForcast[0]["temperatureMax"] as! Int
//        dayZeroTemperatureMin = weeklyForcast[0]["temperatureMin"] as! Int
//
//        let dayZeroIconString = weeklyForcast[0]["icon"] as! String
//
//        dayZeroIcon = weatherIconFromString(dayZeroIconString)
//
//
//
//        //DAY ONE
//        dayOneTemperatureMax = weeklyForcast[1]["temperatureMax"] as! Int
//        dayOneTemperatureMin = weeklyForcast[1]["temperatureMin"] as! Int
//        let dayOneTimeIntValue = weeklyForcast[1]["sunriseTime"] as! Int
//        dayOneUnixTime = dayOneTimeIntValue
//
//        dayOneTime = weeekDateStringFromUnixtime(dayOneTimeIntValue)
//        let dayOneIconString = weeklyForcast[1]["icon"] as! String
//        dayOneIcon = weatherIconFromString(dayOneIconString)
//
//        dayOneIsClear = isItClearDay(dayOneIconString)
//
//
//        //DAY TWO
//        dayTwoTemperatureMax = weeklyForcast[2]["temperatureMax"] as! Int
//        dayTwoTemperatureMin = weeklyForcast[2]["temperatureMin"] as! Int
//        let dayTwoTimeIntValue = weeklyForcast[2]["sunriseTime"] as! Int
//        dayTwoUnixTime = dayTwoTimeIntValue
//
//        dayTwoTime = weeekDateStringFromUnixtime(dayTwoTimeIntValue)
//        let dayTwoIconString = weeklyForcast[2]["icon"] as! String
//        dayTwoIcon = weatherIconFromString(dayTwoIconString)
//
//        dayTwoIsClear = isItClearDay(dayTwoIconString)
//
//
//        //DAY THREE
//        dayThreeTemperatureMax = weeklyForcast[3]["temperatureMax"] as! Int
//        dayThreeTemperatureMin = weeklyForcast[3]["temperatureMin"] as! Int
//        let dayThreeTimeIntValue = weeklyForcast[3]["sunriseTime"] as! Int
//        dayThreeUnixTime = dayThreeTimeIntValue
//
//        dayThreeTime = weeekDateStringFromUnixtime(dayThreeTimeIntValue)
//        let dayThreeIconString = weeklyForcast[3]["icon"] as! String
//        dayThreeIcon = weatherIconFromString(dayThreeIconString)
//
//        dayThreeIsClear = isItClearDay(dayThreeIconString)
//
//
//        //DAY FOUR
//        dayFourTemperatureMax = weeklyForcast[4]["temperatureMax"] as! Int
//        dayFourTemperatureMin = weeklyForcast[4]["temperatureMin"] as! Int
//        let dayFourTimeIntValue = weeklyForcast[4]["sunriseTime"] as! Int
//        dayFourUnixTime = dayFourTimeIntValue
//
//        dayFourTime = weeekDateStringFromUnixtime(dayFourTimeIntValue)
//        let dayFourIconString = weeklyForcast[4]["icon"] as! String
//        dayFourIcon = weatherIconFromString(dayFourIconString)
//
//        dayFourIsClear = isItClearDay(dayFourIconString)
//
//
//        //DAY FIVE
//        dayFiveTemperatureMax = weeklyForcast[5]["temperatureMax"] as! Int
//        dayFiveTemperatureMin = weeklyForcast[5]["temperatureMin"] as! Int
//        let dayFiveTimeIntValue = weeklyForcast[5]["sunriseTime"] as! Int
//        dayFiveUnixTime = dayFiveTimeIntValue
//
//        dayFiveTime = weeekDateStringFromUnixtime(dayFiveTimeIntValue)
//        let dayFiveIconString = weeklyForcast[5]["icon"] as! String
//        dayFiveIcon = weatherIconFromString(dayFiveIconString)
//
//        dayFiveIsClear = isItClearDay(dayFiveIconString)
//
//
//        //DAY SIX
//        daySixTemperatureMax = weeklyForcast[6]["temperatureMax"] as! Int
//        daySixTemperatureMin = weeklyForcast[6]["temperatureMin"] as! Int
//        let daySixTimeIntValue = weeklyForcast[6]["sunriseTime"] as! Int
//        daySixUnixTime = daySixTimeIntValue
//
//        daySixTime = weeekDateStringFromUnixtime(daySixTimeIntValue)
//        let daySixIconString = weeklyForcast[6]["icon"] as! String
//        daySixIcon = weatherIconFromString(daySixIconString)
//
//        daySixIsClear = isItClearDay(daySixIconString)

        
    }
    
    
}

















