//
//  SunriseSunset.swift
//  MyLocations
//
//  Created by Anton Novoselov on 16/07/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit


struct SunriseSunset {
    
    var sunriseTime: String
    var sunsetTime: String
    
    
    init(responseDictionary: NSDictionary) {
        
        let results = responseDictionary["results"] as! NSDictionary
        
        let sunriseTimeRaw = results["sunrise"] as! String
        let sunsetTimeRaw = results["sunset"] as! String
        
        let tempStrSunrise = sunriseTimeRaw as NSString
        let tempStrSunset = sunsetTimeRaw as NSString
        
        let separatorsSet = NSCharacterSet.init(charactersInString: "T+")
        
        let sunriseComponents = tempStrSunrise.componentsSeparatedByCharactersInSet(separatorsSet)
        let sunsetComponents = tempStrSunset.componentsSeparatedByCharactersInSet(separatorsSet)
        
        sunriseTime = sunriseComponents[1]
        sunsetTime = sunsetComponents[1]
        
        
    }
    
    
    
    
    
    
}

