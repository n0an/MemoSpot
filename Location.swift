//
//  Location.swift
//  MyLocations
//
//  Created by Anton Novoselov on 18/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Location: NSManagedObject, MKAnnotation {
    
    // MARK: - PHOTO FEATURE PROPERTIES AND METHODS
    
    var hasPhoto: Bool {
        
        return photoID != nil
    }
    
    var photoPath: String {
        
        assert(photoID != nil, "No photo ID set")
        
        let filename = "Photo-\(photoID!.intValue).jpg"
        
        return (applicationDocumentsDirectory as NSString).appendingPathComponent(filename)
    }
    
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoPath)
    }
   
    
    class func nextPhotoID() -> Int {
        
        let userDefaults = UserDefaults.standard
        
        let currentID = userDefaults.integer(forKey: "PhotoID")
        
        userDefaults.set(currentID + 1, forKey: "PhotoID")
        
        userDefaults.synchronize()
        
        return currentID
    }
    
    
    // MARK: - DELETING FILE
    
    func removePhotoFile() {
        
        if hasPhoto {
            
        let path = photoPath
        
            let fileManager = FileManager.default
            
            if fileManager.fileExists(atPath: path) {
                
                do {
                    try fileManager.removeItem(atPath: path)
                } catch {
                    
                
                }
            
            }
        }
    
    }
    

    
    
    // MARK: - MKAnnotation PROPERTIES
    
    var coordinate: CLLocationCoordinate2D {
        
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    var title: String? {
        
        if locationDescription.isEmpty {
            return "(No Description)"
        
        } else {
            
            return locationDescription
        }
    }
    
    
    var subtitle: String? {
        
        return category
    }


}
