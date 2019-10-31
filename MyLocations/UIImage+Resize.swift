//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by nag on 19.06.16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

extension UIImage {
    
    func resizedImageWithBounds(_ bounds: CGSize) -> UIImage {
        
        let horizontalRatio = bounds.width / size.width
        
        let verticalRatio = bounds.height / size.height
        
        let ratio = max(horizontalRatio, verticalRatio) // max - Aspect Fill, min - Aspect Fit
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage!
    
    }
}
