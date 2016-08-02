//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Anton Novoselov on 20/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//



import UIKit


class MyTabBarController: UITabBarController {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        return .LightContent
    
    }
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        
        return nil
    }

}