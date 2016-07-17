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
    
    var dayZeroTemperatureMax: Int
    var dayZeroTemperatureMin: Int
    
    var sunriseTime: Int
    var sunsetTime: Int
    
    var dayZeroIcon: UIImage
    
    var dayOneTemperatureMax: Int
    var dayOneTemperatureMin: Int
    var dayOneTime: String?
    
    var dayOneIcon: UIImage
    var dayOneIsClear: Bool
    
    var dayTwoTemperatureMax: Int
    var dayTwoTemperatureMin: Int
    var dayTwoTime: String?
    
    var dayTwoIcon: UIImage
    var dayTwoIsClear: Bool

    var dayThreeTemperatureMax: Int
    var dayThreeTemperatureMin: Int
    var dayThreeTime: String?
    
    var dayThreeIcon: UIImage
    var dayThreeIsClear: Bool

    var dayFourTemperatureMax: Int
    var dayFourTemperatureMin: Int
    var dayFourTime: String?
    
    var dayFourIcon: UIImage
    var dayFourIsClear: Bool

    var dayFiveTemperatureMax: Int
    var dayFiveTemperatureMin: Int
    var dayFiveTime: String?
    
    var dayFiveIcon: UIImage
    var dayFiveIsClear: Bool

    var daySixTemperatureMax: Int
    var daySixTemperatureMin: Int
    var daySixTime: String?
    
    var daySixIcon: UIImage
    var daySixIsClear: Bool

    
    
    init (weatherDictionary: NSDictionary) {
        
        offset = weatherDictionary["offset"] as! Int
        
        let weeklyWeather = weatherDictionary["daily"] as! NSDictionary
        
        let weeklyForcast = weeklyWeather["data"] as! NSArray
        
        sunriseTime = weeklyForcast[0]["sunriseTime"] as! Int
        
        sunsetTime = weeklyForcast[0]["sunsetTime"] as! Int

        
        //DAY ZERO
        dayZeroTemperatureMax = weeklyForcast[0]["temperatureMax"] as! Int
        dayZeroTemperatureMin = weeklyForcast[0]["temperatureMin"] as! Int
        
        let dayZeroIconString = weeklyForcast[0]["icon"] as! String

        dayZeroIcon = weatherIconFromString(dayZeroIconString)
        
        
        
        //DAY ONE
        dayOneTemperatureMax = weeklyForcast[1]["temperatureMax"] as! Int
        dayOneTemperatureMin = weeklyForcast[1]["temperatureMin"] as! Int
        let dayOneTimeIntValue = weeklyForcast[1]["sunriseTime"] as! Int
        dayOneTime = weeekDateStringFromUnixtime(dayOneTimeIntValue)
        let dayOneIconString = weeklyForcast[1]["icon"] as! String
        dayOneIcon = weatherIconFromString(dayOneIconString)
        
        dayOneIsClear = isItClearDay(dayOneIconString)
        
        
        //DAY TWO
        dayTwoTemperatureMax = weeklyForcast[2]["temperatureMax"] as! Int
        dayTwoTemperatureMin = weeklyForcast[2]["temperatureMin"] as! Int
        let dayTwoTimeIntValue = weeklyForcast[2]["sunriseTime"] as! Int
        dayTwoTime = weeekDateStringFromUnixtime(dayTwoTimeIntValue)
        let dayTwoIconString = weeklyForcast[2]["icon"] as! String
        dayTwoIcon = weatherIconFromString(dayTwoIconString)
        
        dayTwoIsClear = isItClearDay(dayTwoIconString)

        
        //DAY THREE
        dayThreeTemperatureMax = weeklyForcast[3]["temperatureMax"] as! Int
        dayThreeTemperatureMin = weeklyForcast[3]["temperatureMin"] as! Int
        let dayThreeTimeIntValue = weeklyForcast[3]["sunriseTime"] as! Int
        dayThreeTime = weeekDateStringFromUnixtime(dayThreeTimeIntValue)
        let dayThreeIconString = weeklyForcast[3]["icon"] as! String
        dayThreeIcon = weatherIconFromString(dayThreeIconString)
        
        dayThreeIsClear = isItClearDay(dayThreeIconString)

        
        //DAY FOUR
        dayFourTemperatureMax = weeklyForcast[4]["temperatureMax"] as! Int
        dayFourTemperatureMin = weeklyForcast[4]["temperatureMin"] as! Int
        let dayFourTimeIntValue = weeklyForcast[4]["sunriseTime"] as! Int
        dayFourTime = weeekDateStringFromUnixtime(dayFourTimeIntValue)
        let dayFourIconString = weeklyForcast[4]["icon"] as! String
        dayFourIcon = weatherIconFromString(dayFourIconString)
        
        dayFourIsClear = isItClearDay(dayFourIconString)

        
        //DAY FIVE
        dayFiveTemperatureMax = weeklyForcast[5]["temperatureMax"] as! Int
        dayFiveTemperatureMin = weeklyForcast[5]["temperatureMin"] as! Int
        let dayFiveTimeIntValue = weeklyForcast[5]["sunriseTime"] as! Int
        dayFiveTime = weeekDateStringFromUnixtime(dayFiveTimeIntValue)
        let dayFiveIconString = weeklyForcast[5]["icon"] as! String
        dayFiveIcon = weatherIconFromString(dayFiveIconString)
        
        dayFiveIsClear = isItClearDay(dayFiveIconString)

        
        //DAY SIX
        daySixTemperatureMax = weeklyForcast[6]["temperatureMax"] as! Int
        daySixTemperatureMin = weeklyForcast[6]["temperatureMin"] as! Int
        let daySixTimeIntValue = weeklyForcast[6]["sunriseTime"] as! Int
        daySixTime = weeekDateStringFromUnixtime(daySixTimeIntValue)
        let daySixIconString = weeklyForcast[6]["icon"] as! String
        daySixIcon = weatherIconFromString(daySixIconString)
        
        daySixIsClear = isItClearDay(daySixIconString)

        
    }
    
    
}

















