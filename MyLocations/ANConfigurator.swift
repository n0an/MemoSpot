//
//  ANConfigurator.swift
//  MyLocations
//
//  Created by Anton Novoselov on 16/07/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

let apiKey = "da80aefa4ec207511622f3af58b36013"  // https://developer.forecast.io

class ANConfigurator {
    
    static let sharedConfigurator = ANConfigurator()
    
    // MARK: - PRIVATE METHODS
    
    fileprivate func coloredImage(_ image: UIImage, red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIImage! {
        
        let rect = CGRect(origin: CGPoint.zero, size: image.size)
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        
        let context = UIGraphicsGetCurrentContext()
        
        image.draw(in: rect)
        
        
        context?.setFillColor(red: red, green: green, blue: blue, alpha: alpha)
        context?.setBlendMode(CGBlendMode.sourceAtop)
        
        context?.fill(rect)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return result
        
    }
    
    
    
    lazy var dateFormatter: DateFormatter = {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd.MM.YYYY"
        
        return dateFormatter
    }()
    
    
    
    lazy var calendar: Calendar = {
        let calendar = Calendar.current
        
        return calendar
    }()
    
    
    
    
    // MARK: - PUBLIC METHODS
    
    func customizeSlider(_ slider: UISlider) {
        // Custom Slider
        let thumbImageNormal = UIImage(named: "SliderThumb-Normal")
        slider.setThumbImage(thumbImageNormal, for: UIControl.State())
        
        let thumbImageHighlighted = UIImage(named: "SliderThumb-Highlighted")
        slider.setThumbImage(thumbImageHighlighted, for: .highlighted)
        
        let insets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        
        if let trackLeftImage = UIImage(named: "SliderTrackLeft1") {
            let trackLeftResizable = trackLeftImage.resizableImage(withCapInsets: insets)
            slider.setMinimumTrackImage(trackLeftResizable, for: UIControl.State())
        }
        if let trackRightImage = UIImage(named: "SliderTrackRight1") {
            let trackRightResizable = trackRightImage.resizableImage(withCapInsets: insets)
            slider.setMaximumTrackImage(trackRightResizable, for: UIControl.State())
        }
        
    }
   
    
    
    
    
}

