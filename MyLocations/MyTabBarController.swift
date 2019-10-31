//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Anton Novoselov on 20/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//



import UIKit


class MyTabBarController: UITabBarController {
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        
        return .lightContent
    
    }
    
    override var childViewControllerForStatusBarStyle : UIViewController? {
        
        return nil
    }

}
