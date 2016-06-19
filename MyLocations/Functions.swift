//
//  Functions.swift
//  MyLocations
//
//  Created by Anton Novoselov on 18/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation


let applicationDocumentsDirectory: String = {
    
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    
    
    print("paths = \(paths)")
    
    return paths[0]
    
    
}()


func afterDelay(seconds: Double, closure: ()->()) {
    
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    
    dispatch_after(when, dispatch_get_main_queue(), closure)
    
}










