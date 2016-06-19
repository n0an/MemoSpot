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
