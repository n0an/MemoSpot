//
//  Functions.swift
//  MyLocations
//
//  Created by Anton Novoselov on 18/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation


let applicationDocumentsDirectory: String = {
    
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    
    return paths[0]
    
    
}()



func afterDelay(_ seconds: Double, closure: @escaping ()->()) {
    
    let when = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    
}










