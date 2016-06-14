//
//  FirstViewController.swift
//  MyLocations
//
//  Created by nag on 14.06.16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    @IBAction func getLocation() {
        
        // Get user permission to share location
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .Denied || authStatus == .Restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    
    func showLocationServicesDeniedAlert() {
        
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alert.addAction(okAction)

        presentViewController(alert, animated: true, completion: nil)
    
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


// MARK: - CLLocationManagerDelegate
extension CurrentLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError \(error)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        
        print("didUpdateLocations \(newLocation)")
    }
    
    
}






















